//
//  Meta+Entity.swift
//  
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import Foundation

extension Meta {
    public class Entity {
        public var range: NSRange
        public let meta: Meta
        
        public init(range: NSRange, meta: Meta) {
            self.range = range
            self.meta = meta
        }
    }
}

extension Meta.Entity {
    public var primaryText: String {
        switch self.meta {
        case .url(let text, _, _, _):
            // fix emoji not accepted by AttributedString issue
            return URLComponents(string: text)?.url?.absoluteString ?? text
        case .emoji(let text, _, _, _):         return text
        case .hashtag(let text, _, _):          return text
        case .cashtag(let text, _, _):          return text
        case .mention(let text, _, _):          return text
        case .email(let text, _):               return text
        }
    }
}

extension Meta.Entity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{\(range.debugDescription), \(primaryText)"
    }
}
