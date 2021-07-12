//
//  File.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-25.
//

import Foundation
import Fuzi

extension MastodonMetaContent {

    class Node {

        let level: Int
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
                if tagName == "a" {
                    if _classNames.contains("u-url") {
                        return .mention
                    }
                    if _classNames.contains("hashtag") {
                        return .hashtag
                    }
                    return .url
                } else {
                    if _classNames.contains("emoji") {
                        return .emoji
                    }
                    return nil
                }
            }()
            self.level = level
            self.type = _type
            self.text = text
            self.tagName = tagName
            self.attributes = attributes
            self.href = href
            self.hrefEllipsis = hrefEllipsis
            self.children = children
        }

        static func parse(document: String) throws -> MastodonMetaContent.Node {
            let document = document
                .replacingOccurrences(of: "<br>|<br />", with: "\u{2028}", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "</p>", with: "</p>\u{2029}", range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let html = try HTMLDocument(string: document)

            let body = html.body ?? nil
            let text = body?.stringValue ?? ""
            let level = 0
            let children: [MastodonMetaContent.Node] = body.flatMap { body in
                return Node.parse(element: body, parentText: text[...], parentLevel: level + 1)
            } ?? []
            let node = Node(
                level: level,
                text: text[...],
                tagName: body?.tag,
                attributes: body?.attributes ?? [:],
                href: nil,
                hrefEllipsis: nil,
                children: children
            )

            return node
        }

        static func parse(element: XMLElement, parentText: Substring, parentLevel: Int) -> [Node] {
            let parent = element
            let scanner = Scanner(string: String(parentText))
            scanner.charactersToBeSkipped = .none

            var children: [Node] = []
            for _element in parent.children {
                let _text = _element.stringValue

                // scan element text
                _ = scanner.scanUpToString(_text)
                let startIndexOffset = scanner.currentIndex.utf16Offset(in: scanner.string)
                guard scanner.scanString(_text) != nil else {
                    assertionFailure()
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
                let node = Node(
                    level: level,
                    text: text,
                    tagName: _element.tag,
                    attributes: _element.attributes,
                    href: href,
                    hrefEllipsis: hrefEllipsis,
                    children: Node.parse(element: _element, parentText: text, parentLevel: level + 1)
                )
                children.append(node)
            }

            return children
        }

        static func collect(
            node: Node,
            where predicate: (Node) -> Bool
        ) -> [Node] {
            var nodes: [Node] = []

            if predicate(node) {
                nodes.append(node)
            }

            for child in node.children {
                nodes.append(contentsOf: Node.collect(node: child, where: predicate))
            }
            return nodes
        }

    }

}

extension MastodonMetaContent.Node {
    enum `Type` {
        case url
        case mention
        case hashtag
        case emoji
    }

    static func entities(in node: MastodonMetaContent.Node) -> [MastodonMetaContent.Node] {
        return MastodonMetaContent.Node.collect(node: node) { node in node.type != nil }
    }

    static func entities(in node: MastodonMetaContent.Node, for type: Type) -> [MastodonMetaContent.Node] {
        return MastodonMetaContent.Node.collect(node: node) { node in node.type == type }
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
