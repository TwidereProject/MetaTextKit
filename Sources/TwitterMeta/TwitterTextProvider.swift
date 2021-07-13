//
//  TwitterTextProvider.swift
//  
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import Foundation

public protocol TwitterTextProvider {
    func entities(in text: String) -> [TwitterTextProviderEntity]
}

public enum TwitterTextProviderEntity {
    case url(range: NSRange)
    case screenName(range: NSRange)
    case hashtag(range: NSRange)
    case listName(range: NSRange)
    case symbol(range: NSRange)
    case tweetChar(range: NSRange)
    case tweetEmojiChar(range: NSRange)

    var range: NSRange {
        switch self {
        case .url(let range),
            .screenName(let range),
            .hashtag(let range),
            .listName(let range),
            .symbol(let range),
            .tweetChar(let range),
            .tweetEmojiChar(let range):
            return range
        }
    }
}
