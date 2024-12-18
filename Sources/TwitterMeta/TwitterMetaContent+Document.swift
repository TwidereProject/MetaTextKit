//
//  TwitterMetaContent+Document.swift
//  
//
//  Created by MainasuK on 2023/4/3.
//

import Foundation
import Meta

extension TwitterMetaContent {

    public static func convert(
        document content: TwitterContent,
        urlMaximumLength: Int,
        twitterTextProvider: TwitterTextProvider,
        addtionalMetaProvider: MetaProvider? = nil,
        useParagraphMark: Bool = false
    ) -> TwitterMetaContent {
        var entities: [Meta.Entity] = []
        
        // Rich Text Entity
        let richTextEntities: [Meta.Entity] = {
            let nsContent = content.content as NSString
            let nsContentRange = NSRange(location: 0, length: nsContent.length)
            let entities = content.richTextTags.compactMap { tag -> Meta.Entity? in
                guard let range = tag.range.intersection(nsContentRange), range.length > 0 else { return nil }
                let text = nsContent.substring(with: range)
                let styles = tag.types.compactMap { $0.metaStyleType }
                return Meta.Entity(
                    range: range,
                    meta: .style(text, styles: styles, userInfo: nil)
                )
            }
            let orderedEntities = entities.sorted(by: { $0.range.location < $1.range.location })
            return orderedEntities
        }()
        entities.append(contentsOf: richTextEntities)

        // inline media
        let inlineMediaEntities: [Meta.Entity] = {
            let nsContent = content.content as NSString
            let nsContentRange = NSRange(location: 0, length: nsContent.length)
            let entities = content.inlineMedia.compactMap { item -> Meta.Entity? in
                guard let range = item.range.intersection(nsContentRange), range.location != NSNotFound else { return nil }
                let text = nsContent.substring(with: range)
                return Meta.Entity(
                    range: range,
                    meta: .media(text, url: item.url, userInfo: ["inlineMedia": item])
                )
            }
            let orderedEntities = entities.sorted(by: { $0.range.location < $1.range.location })
            return orderedEntities
        }()
        entities.append(contentsOf: inlineMediaEntities)

        let original: String = {
            if useParagraphMark {
                return Meta.replaceParagraphMark(content: content.content, orderedEntities: richTextEntities)
            } else {
                return content.content
            }
        }()

        // TwitterText Entity
        let twitterTextEntities = twitterTextProvider.entities(in: original)
            .sorted(by: { $0.range.location < $1.range.location })
        for twitterTextEntity in twitterTextEntities {
            let range = twitterTextEntity.range
            guard let text = original.string(in: range) else { continue }
            switch twitterTextEntity {
            case .url:
                guard let urlEntity = content.urlEntities.first(where: { $0.url == text }),
                      let displayURL = urlEntity.displayURL,
                      let expandedURL = urlEntity.expandedURL
                else {
                    let entity = Meta.Entity(
                        range: range,
                        meta: .url(text, trimmed: text.dropHTTPPrefix().trim(to: urlMaximumLength), url: text, userInfo: nil)
                    )
                    entities.append(entity)
                    continue
                }
                let trimmed = displayURL
                let url = expandedURL
                let userInfo: [AnyHashable: Any] = [
                    "urlEntity": urlEntity
                ]
                let entity = Meta.Entity(
                    range: range,
                    meta: .url(text, trimmed: trimmed, url: url, userInfo: userInfo)
                )
                entities.append(entity)
            case .screenName:
                let mention = text.hasPrefix("@") ? String(text.dropFirst()) : text
                let entity = Meta.Entity(
                    range: range,
                    meta: .mention(text, mention: mention, userInfo: nil)
                )
                entities.append(entity)
            case .hashtag:
                let hashtag = text.hasPrefix("#") ? String(text.dropFirst()) : text
                let entity = Meta.Entity(
                    range: range,
                    meta: .hashtag(text, hashtag: hashtag, userInfo: nil)
                )
                entities.append(entity)
            case .listName:
                continue
            case .symbol:
                let cashtag = String(text.dropFirst())
                let entity = Meta.Entity(
                    range: range,
                    meta: .cashtag(text, cashtag: cashtag, userInfo: nil)
                )
                entities.append(entity)
            case .tweetChar:
                continue
            case .tweetEmojiChar:
                continue
            }
        }

        // addtional meta entity
        if let addtionalMetaProvider {
            let addionalEntities = addtionalMetaProvider.parse(content: original, entities: entities)
            let orderedAddionalEntities = addionalEntities.sorted(by: { $0.range.location < $1.range.location })
            for addionalEntity in orderedAddionalEntities {
                let range = addionalEntity.range
                let isIntersection = entities.contains(where: { entity in
                    switch entity.meta {
                    case .style:
                        return false
                    default:
                        return entity.range.intersection(range) != nil
                    }
                })
                guard !isIntersection else { continue }
                entities.append(addionalEntity)
            }
        }

        // result should be ordered
        let orderedEntities = entities.sorted(by: {
            $0.range.location < $1.range.location
        })
        let trimmed = Meta.trim(content: original, orderedEntities: orderedEntities)

        return TwitterMetaContent(
            original: original,
            trimmed: trimmed,
            entities: orderedEntities
        )
    }

}

fileprivate extension String {
    func string(in nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return String(self[range])
    }

    func trim(to maximumCharacters: Int) -> String {
        guard maximumCharacters > 0, count > maximumCharacters else {
            return self
        }
        return "\(self[..<index(startIndex, offsetBy: maximumCharacters)])" + "..."
    }
    
    func dropHTTPPrefix() -> String {
        if self.lowercased().hasPrefix("https://") {
            return String(self.dropFirst("https://".count))
        } else if self.lowercased().hasPrefix("http://") {
            return String(self.dropFirst("http://".count))
        } else {
            return self
        }
    }
}
