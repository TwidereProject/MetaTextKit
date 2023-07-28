//
//  MastodonMetaContent+Document.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-26.
//

import Foundation
import Meta
import Fuzi

extension MastodonMetaContent {

    public static func convert(document content: MastodonContent) throws -> MastodonMetaContent {
        let document: HTMLDocument = try {
            do {
                return try content.preprocess()
            } catch {
                let string = content.content.trimmingCharacters(in: .whitespacesAndNewlines)
                return try HTMLDocument(string: string, encoding: .utf8)
            }
        }()
        let rootNode = try Node.parse(document: document)
        let rootText = String(rootNode.text)

        var metaEntities: [Meta.Entity] = []
        let metaNodes = MastodonMetaContent.Node.entities(in: rootNode)
        for node in metaNodes {
            let range = NSRange(node.text.startIndex..<node.text.endIndex, in: rootText)

            let nodeText = String(node.text)
            switch node.type {
            case .url:
                guard let href = node.href else { continue }
                let trimmed: String = {
                    if let hrefEllipsis = node.hrefEllipsis {
                        return hrefEllipsis + "…"
                    } else {
                        return nodeText
                    }
                }()
                let entity = Meta.Entity(
                    range: range,
                    meta: .url(nodeText, trimmed: trimmed, url: href, userInfo: nil)
                )
                metaEntities.append(entity)
            case .hashtag:
                var userInfo: [AnyHashable: Any] = [:]
                node.href.flatMap { href in
                    userInfo["href"] = href
                }
                let hashtag = nodeText.deletingPrefix("#")
                let entity = Meta.Entity(
                    range: range,
                    meta: .hashtag(nodeText, hashtag: hashtag, userInfo: userInfo)
                )
                metaEntities.append(entity)
            case .mention:
                var userInfo: [AnyHashable: Any] = [:]
                node.href.flatMap { href in
                    userInfo["href"] = href
                }
                let mention = nodeText.deletingPrefix("@")
                let entity = Meta.Entity(
                    range: range,
                    meta: .mention(nodeText, mention: mention, userInfo: userInfo)
                )
                metaEntities.append(entity)
            case .emoji:
                guard let href = node.href else { continue }
                guard let shortcode = node.attributes["shortcode"] else { continue }
                let string = ":\(shortcode):"
                let entity = Meta.Entity(
                    range: range,
                    meta: .emoji(string, shortcode: shortcode, url: href, userInfo: nil)
                )
                metaEntities.append(entity)
            case .formatted(.strong):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .strong)))
            case .formatted(.emphasized):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .emphasized)))
            case .formatted(.underlined):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .underlined)))
            case .formatted(.strikethrough):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .strikethrough)))
            case .formatted(.code):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .code)))
            case .formatted(.orderedList):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .orderedList)))
            case .formatted(.unorderedList):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .unorderedList)))
            case .formatted(.listItem(let indentLevel)):
                metaEntities.append(Meta.Entity(range: range, meta: .formatted(nodeText, .listItem(indentLevel: indentLevel))))
            case .none:
                continue
            }
        }

        let trimmed = Meta.trim(content: rootText, orderedEntities: metaEntities)

        return MastodonMetaContent(
            document: content.content,
            original: rootText,
            trimmed: trimmed,
            entities: metaEntities
        )
    }

}

extension String {
    // ref: https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

