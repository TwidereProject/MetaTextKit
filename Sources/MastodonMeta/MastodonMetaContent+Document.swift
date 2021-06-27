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
        let document: String = {
            var document = content.content
            for (shortcode, url) in content.emojis {
                let emojiNode = #"<span class="emoji" href="\#(url)" shortcode="\#(shortcode)">:\#(shortcode):</span>"#
                let pattern = ":\(shortcode):"
                document = document.replacingOccurrences(of: pattern, with: emojiNode)
            }
            return document.trimmingCharacters(in: .whitespacesAndNewlines)
        }()
        let rootNode = try Node.parse(document: document)
        let text = String(rootNode.text)

        var metaEntities: [Meta.Entity] = []
        let metaNodes = MastodonMetaContent.Node.entities(in: rootNode)
        for node in metaNodes {
            let range = NSRange(node.text.startIndex..<node.text.endIndex, in: text)

            switch node.type {
            case .url:
                guard let href = node.href else { continue }
                let text = String(node.text)
                let entity = Meta.Entity(
                    range: range,
                    meta: .url(text, trimmed: node.hrefEllipsis ?? text, url: href, userInfo: nil)
                )
                metaEntities.append(entity)
            case .hashtag:
                var userInfo: [AnyHashable: Any] = [:]
                node.href.flatMap { href in
                    userInfo["href"] = href
                }
                let string = String(node.text)
                let hashtag = string.deletingPrefix("#")
                let entity = Meta.Entity(
                    range: range,
                    meta: .hashtag(string, hashtag: hashtag, userInfo: userInfo)
                )
                metaEntities.append(entity)
            case .mention:
                var userInfo: [AnyHashable: Any] = [:]
                node.href.flatMap { href in
                    userInfo["href"] = href
                }
                let string = String(node.text)
                let mention = string.deletingPrefix("@")
                let entity = Meta.Entity(
                    range: range,
                    meta: .mention(string, mention: mention, userInfo: userInfo)
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
            case .none:
                continue
            }
        }

        var trimmed = text
        for entity in metaEntities {
            trim(content: &trimmed, entity: entity, entities: metaEntities)
        }

        return MastodonMetaContent(
            document: document,
            original: text,
            trimmed: trimmed,
            entities: metaEntities
        )
    }

    static func trim(content: inout String, entity: Meta.Entity, entities: [Meta.Entity]) {
        let text: String
        let trimmed: String
        switch entity.meta {
        case .url(let _text, let _trimmed, _, _):
            text = _text
            trimmed = _trimmed
        case .emoji(let _text, _, _, _):
            text = _text
            trimmed = " "
        default:
            return
        }

        guard let index = entities.firstIndex(where: { $0.range == entity.range }) else { return }
        guard let range = Range(entity.range, in: content) else { return }
        content.replaceSubrange(range, with: trimmed)

        let offset = trimmed.count - text.count
        entity.range.length += offset

        let moveEntities = Array(entities[index...].dropFirst())
        for moveEntity in moveEntities {
            moveEntity.range.location += offset
        }
    }

}

extension String {
    // ref: https://www.hackingwithswift.com/example-code/strings/how-to-remove-a-prefix-from-a-string
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

