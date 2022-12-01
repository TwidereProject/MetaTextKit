//
//  TwitterMetaContent+Text.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import Foundation
import Meta

extension TwitterMetaContent {

    public static func convert(
        content: TwitterContent,
        urlMaximumLength: Int,
        twitterTextProvider: TwitterTextProvider
    ) -> TwitterMetaContent {
        let original = content.content
        var entities: [Meta.Entity] = []
        let twitterTextEntities = twitterTextProvider.entities(in: original)
            .sorted(by: { $0.range.location < $1.range.location })

        for twitterTextEntity in twitterTextEntities {
            let range = twitterTextEntity.range
            guard let text = original.string(in: range) else { continue }
            switch twitterTextEntity {
            case .url:
                let trimmed: String = {
                    if text.lowercased().hasPrefix("https://") {
                        return String(text.dropFirst("https://".count)).trim(to: urlMaximumLength)
                    } else if text.lowercased().hasPrefix("http://") {
                        return String(text.dropFirst("http://".count)).trim(to: urlMaximumLength)
                    } else {
                        return text.trim(to: urlMaximumLength)
                    }
                }()
                let entity = Meta.Entity(
                    range: range,
                    meta: .url(text, trimmed: trimmed, url: text, userInfo: nil)
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
                continue
            case .tweetChar:
                continue
            case .tweetEmojiChar:
                continue
            }
        }

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
}
