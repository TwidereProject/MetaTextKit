//
//  MastodonContent+Preprocessor.swift
//  
//
//  Created by MainasuK on 2023-07-28.
//

import os.log
import Foundation
import Fuzi

extension MastodonContent {
    func preprocess() throws -> HTMLDocument {
        // 1. parepare the document
        let content: String = {
            var content = self.content
            for (shortcode, url) in emojis {
                let node = #"<span class="emoji" href="\#(url)" shortcode="\#(shortcode)">:\#(shortcode):</span>"#
                let pattern = ":\(shortcode):"
                content = content.replacingOccurrences(of: pattern, with: node)
            }
            content = content
                .replacingOccurrences(of: "<h1>|<h2>|<h3>|<h4>|<h5>|<h6>", with: "<p><strong>", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "</h1>|</h2>|</h3>|</h4>|</h5>|</h6>", with: "</strong></p>", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "<br>|<br />", with: "\u{2028}", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "</pre>", with: "</pre>\u{2029}", range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return content
        }()
        let document = try HTMLDocument(string: content, encoding: .utf8)
        guard let body = document.body else {
            return document
        }

        // 2. recursion the node and collect the mapping infos
        let scanner = Scanner(string: body.rawXMLDump)
        scanner.charactersToBeSkipped = .none
        
        let _tree = MastodonContent.PreprocessInfo.preprocess(
            node: body,
            attribute: PreprocessInfo.Attribute(
                level: 0,
                levelForList: 0
            ),
            scanner: scanner
        )
        guard let tree = _tree else {
            return document
        }

        // 3. map tree to array
        let array = MastodonContent.PreprocessInfo.collect(node: tree) { info in
            return true
        }
        
        // 4. update document from end to start
        var text = tree.text
        let operations = array
            .map { $0.operations }
            .flatMap { $0 }
            .sorted(by: { text.distance(from: $0.range.upperBound, to: $1.range.lowerBound) > 0 })
            .reversed()
        for operation in operations {
            text = operation.operate(text)
        }
        
        do {
            text = text
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let document = try HTMLDocument(string: text, encoding: .utf8)
            return document
        } catch {
            return document
        }
    }
}

extension MastodonContent {
    struct PreprocessInfo {
        let node: Fuzi.XMLElement
        let text: String
        let range: Range<String.Index>
        let attribute: Attribute
        let children: [PreprocessInfo]
    }
}

extension MastodonContent.PreprocessInfo {
    struct Attribute {
        let level: Int
        let levelForList: Int
    }
    
    enum Operation {
        case insert(range: Range<String.Index>, content: String)
        case remove(range: Range<String.Index>)
        
        var range: Range<String.Index> {
            switch self {
            case .insert(let operationRange, _): return operationRange
            case .remove(let operationRange): return operationRange
            }
        }
        
        func operate(_ text: String) -> String {
            var text = text
            switch self {
            case .insert(let operationRange, let content):
                text.insert(contentsOf: content, at: operationRange.lowerBound)
            case .remove(let operationRange):
                text.replaceSubrange(operationRange, with: "")
            }
            return text
        }
    }   // end enum
    
    var isOrderedListItem: Bool? {
        var parent = node.parent
        repeat {
            switch parent?.tag {
            case "ol": return true
            case "ul": return false
            default: break
            }
            parent = parent?.parent
        } while parent != nil
        return nil
    }
    
    var indexOfListItem: Int {
        guard let parent = node.parent else { return 0 }
        guard let index = parent.children.firstIndex(of: node) else { return 0 }
        return index
    }
}

extension MastodonContent.PreprocessInfo {
    var operations: [Operation] {
        var operations: [Operation] = []
        switch node.tag {
        case "p":
            if let closeTagRange = text.range(of: "</p>", options: .backwards, range: range) {
                operations.append(.insert(range: closeTagRange.lowerBound..<closeTagRange.lowerBound, content: "\u{2029}"))
            }
        case "li":
            if let openTagRange = text.range(of: "<li>", options: [], range: range) {
                let indent = String(repeating: "\t", count: attribute.levelForList)
                let index: String = {
                    if isOrderedListItem == true {
                        let index = indexOfListItem + 1
                        return "\(index). "
                    } else {
                        return "- "
                    }
                }()
                operations.append(.insert(range: openTagRange.upperBound..<openTagRange.upperBound, content: indent + index))
            }
            if let closeTagRange = text.range(of: "</li>", options: .backwards, range: range), node.nextSibling?.tag == "li" {
                operations.append(.insert(range: closeTagRange.lowerBound..<closeTagRange.lowerBound, content: "\u{2029}"))
            }
        case "ul":
            if let openTagRange = text.range(of: "<ul>", options: [], range: range),
               let parent = node.parent, parent.tag == "li" {
                operations.append(.insert(range: openTagRange.lowerBound..<openTagRange.lowerBound, content: "\u{2029}"))
            }
            if let closeTagRange = text.range(of: "</ul>", options: .backwards, range: range), attribute.levelForList == 1 {
                operations.append(.insert(range: closeTagRange.lowerBound..<closeTagRange.lowerBound, content: "\u{2029}"))
            }
        case "ol":
            if let openTagRange = text.range(of: "<ol>", options: [], range: range),
               let parent = node.parent, parent.tag == "li" {
                operations.append(.insert(range: openTagRange.lowerBound..<openTagRange.lowerBound, content: "\u{2029}"))
            }
            if let closeTagRange = text.range(of: "</ol>", options: .backwards, range: range), attribute.levelForList == 1 {
                operations.append(.insert(range: closeTagRange.lowerBound..<closeTagRange.lowerBound, content: "\u{2029}"))
            }
        default:
            break
        }
        return operations
    }
}

extension MastodonContent.PreprocessInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        let indent = String(repeating: "\t", count: attribute.level)
        var description = #"\#(indent)[\#(attribute.level)/\#(attribute.levelForList)]: \#(node.rawXML.rawRepresent)\"# + "\n"
        description += children.map { $0.debugDescription }.joined()
        return description
    }
}


extension MastodonContent.PreprocessInfo {
    static func preprocess(
        node: Fuzi.XMLElement,
        attribute: MastodonContent.PreprocessInfo.Attribute,
        scanner: Scanner
    ) -> MastodonContent.PreprocessInfo? {
        let text = node.rawXMLDump
        let _range = scanner.string.range(
            of: text,
            options: [],
            range: scanner.currentIndex..<scanner.string.endIndex
        )
        guard let range = _range else {
            return nil
        }
        
        let attribute = MastodonContent.PreprocessInfo.Attribute(
            level: attribute.level + 1,
            levelForList: attribute.levelForList + (node.isList ? 1 : 0)
        )
        
        let children = node.children.compactMap { child in
            _ = scanner.scanUpToString(child.rawXMLDump)
            return MastodonContent.PreprocessInfo.preprocess(
                node: child,
                attribute: attribute,
                scanner: scanner
            )
        }
        
        return MastodonContent.PreprocessInfo(
            node: node,
            text: scanner.string,
            range: range,
            attribute: attribute,
            children: children
        )
    }   // end func
    
    static func collect(
        node: MastodonContent.PreprocessInfo,
        where predicate: (MastodonContent.PreprocessInfo) -> Bool
    ) -> [MastodonContent.PreprocessInfo] {
        var nodes: [MastodonContent.PreprocessInfo] = []
        
        if predicate(node) {
            nodes.append(node)
        }
        
        for child in node.children {
            nodes.append(contentsOf: MastodonContent.PreprocessInfo.collect(node: child, where: predicate))
        }
        return nodes
    }
}

extension XMLElement {
    var isList: Bool {
        switch tag {
        case "ol", "ul": return true
        default: return false
        }
    }
}
