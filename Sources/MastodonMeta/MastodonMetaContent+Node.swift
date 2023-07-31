//
//  MastodonMetaContent+Node.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-25.
//

import Foundation
import Fuzi

extension MastodonMetaContent {
    class Node {
        
        let level: Int          // tag depth
        let indentLevel: Int    // list depth
        
        // HTML tag type
        let type: Type?
        
        // substring text
        let text: Substring
        
        // range in parent String
        var range: Range<String.Index> {
            return text.startIndex..<text.endIndex
        }
        
        let tagName: String?
        let attributes: [String : String]
        let href: String?
        let hrefEllipsis: String?
        
        let children: [Node]
        
        init(
            level: Int,
            indentLevel: Int,
            text: Substring,
            tagName: String?,
            attributes: [String : String],
            href: String?,
            hrefEllipsis: String?,
            children: [Node]
        ) {
            let _classNames: Set<String> = {
                guard let className = attributes["class"] else { return Set() }
                return Set(className.components(separatedBy: " "))
            }()
            let _type: Type? = {
                switch tagName {
                case "a":
                    if _classNames.contains("u-url") {
                        return .mention
                    }
                    if _classNames.contains("hashtag") {
                        return .hashtag
                    }
                    return .url
                case "b", "strong":
                    return .formatted(.strong)
                case "i", "em":
                    return .formatted(.emphasized)
                case "u":
                    return .formatted(.underlined)
                case "del":
                    return .formatted(.strikethrough)
                case "pre", "code":
                    return .formatted(.code)
                case "blockquote":
                    return .formatted(.blockquote)
                case "ol":
                    return .formatted(.orderedList)
                case "ul":
                    return .formatted(.unorderedList)
                case "li":
                    return .formatted(.listItem(indentLevel: indentLevel))
                default:
                    if _classNames.contains("emoji") {
                        return .emoji
                    }
                    return nil
                }
            }()
            self.level = level
            self.indentLevel = indentLevel
            self.type = _type
            self.text = text
            self.tagName = tagName
            self.attributes = attributes
            self.href = href
            self.hrefEllipsis = hrefEllipsis
            self.children = children
        }
    }
}

extension MastodonMetaContent.Node {
    enum `Type`: Equatable {
        case url
        case mention
        case hashtag
        case emoji
        case formatted(FormatType)
    }

    enum FormatType: Equatable {
        // b, strong
        case strong
        // i, em
        case emphasized
        // u
        case underlined
        // del
        case strikethrough
        // pre, code
        case code
        // blockquote
        case blockquote
        // ol
        case orderedList
        // ul
        case unorderedList
        // li
        case listItem(indentLevel: Int)
    }

    static func entities(in node: MastodonMetaContent.Node) -> [MastodonMetaContent.Node] {
        return MastodonMetaContent.Node.collect(node: node) { node in node.type != nil }
    }

    static func entities(in node: MastodonMetaContent.Node, for type: Type) -> [MastodonMetaContent.Node] {
        return MastodonMetaContent.Node.collect(node: node) { node in node.type == type }
    }
}

extension MastodonMetaContent.Node {
    static func parse(document: HTMLDocument) throws -> MastodonMetaContent.Node {
        let body = document.body ?? nil
        let text = body?.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let level = 0
        let indentLevel = 0
        let children: [MastodonMetaContent.Node] = body.flatMap { body in
            return MastodonMetaContent.Node.parse(
                element: body,
                parentText: text[...],
                parentLevel: level + 1,
                parentIndentLevel: indentLevel      // not indent for default root
            )
        } ?? []
        let node = MastodonMetaContent.Node(
            level: level,
            indentLevel: indentLevel,
            text: text[...],
            tagName: body?.tag,
            attributes: body?.attributes ?? [:],
            href: nil,
            hrefEllipsis: nil,
            children: children
        )
        
        return node
    }
    
    static func parse(
        element: XMLElement,
        parentText: Substring,
        parentLevel: Int,
        parentIndentLevel: Int
    ) -> [MastodonMetaContent.Node] {
        let parent = element
        let scanner = Scanner(string: String(parentText))
        scanner.charactersToBeSkipped = .none
        
        let parentIsList: Bool = {
            parent.tag == "ol" || parent.tag == "ul"
        }()
        
        var children: [MastodonMetaContent.Node] = []
        for _element in parent.children {
            let _text = _element.stringValue.trimmingCharacters(in: .newlines)
            
            // scan element text
            _ = scanner.scanUpToString(_text)
            let startIndexOffset = scanner.currentIndex.utf16Offset(in: scanner.string)
            guard scanner.scanString(_text) != nil else {
                // FIXME: some emoji break the paser
                // assertionFailure()
                continue
            }
            let endIndexOffset = scanner.currentIndex.utf16Offset(in: scanner.string)
            
            // locate substring
            let startIndex = parentText.utf16.index(parentText.utf16.startIndex, offsetBy: startIndexOffset)
            let endIndex = parentText.utf16.index(parentText.utf16.startIndex, offsetBy: endIndexOffset)
            let text = Substring(parentText.utf16[startIndex..<endIndex])
            
            let href = _element["href"]
            let hrefEllipsis = href.flatMap { _ in _element.firstChild(css: ".ellipsis")?.stringValue }
            
            let level = parentLevel + 1
            let indentLevel = parentIsList ? parentIndentLevel + 1 : parentIndentLevel
            let node = MastodonMetaContent.Node(
                level: level,
                indentLevel: indentLevel,
                text: text,
                tagName: _element.tag,
                attributes: _element.attributes,
                href: href,
                hrefEllipsis: hrefEllipsis,
                children: MastodonMetaContent.Node.parse(
                    element: _element,
                    parentText: text,
                    parentLevel: level + 1,
                    parentIndentLevel: indentLevel
                )
            )
            children.append(node)
        }
        
        return children
    }
    
    static func collect(
        node: MastodonMetaContent.Node,
        where predicate: (MastodonMetaContent.Node) -> Bool
    ) -> [MastodonMetaContent.Node] {
        var nodes: [MastodonMetaContent.Node] = []
        
        if predicate(node) {
            nodes.append(node)
        }
        
        for child in node.children {
            nodes.append(contentsOf: MastodonMetaContent.Node.collect(node: child, where: predicate))
        }
        return nodes
    }
}

extension MastodonMetaContent.Node: CustomDebugStringConvertible {
    var debugDescription: String {
        let linkInfo: String = {
            switch (href, hrefEllipsis) {
            case (nil, nil):
                return ""
            case (let href, let hrefEllipsis):
                return "(\(href ?? "nil") - \(hrefEllipsis ?? "nil"))"
            }
        }()
        let classNamesInfo: String = {
            guard let className = attributes["class"] else { return "" }
            return "@[\(className)]"
        }()
        let nodeDescription = String(
            format: "<%@>%@%@: %@",
            tagName ?? "",
            classNamesInfo,
            linkInfo,
            String(text)
        )
        guard !children.isEmpty else {
            return nodeDescription
        }

        let indent = Array(repeating: "  ", count: level).joined()
        let childrenDescription = children
            .map { indent + $0.debugDescription }
            .joined(separator: "\n")

        return nodeDescription + "\n" + childrenDescription
    }
}
