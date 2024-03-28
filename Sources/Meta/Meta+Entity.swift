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
        case .url(_, _, let url, _):            return url
        case .emoji(let text, _, _, _):         return text
        case .hashtag(let text, _, _):          return text
        case .cashtag(let text, _, _):          return text
        case .mention(let text, _, _):          return text
        case .email(let text, _):               return text
        case .style(let text, _, _):            return text
        }
    }
    
    public var typeName: String {
        switch self.meta {
        case .url: return "url"
        case .emoji: return "emoji"
        case .hashtag: return "hashtag"
        case .cashtag: return "cashtag"
        case .mention: return "mention"
        case .email: return "email"
        case .style: return "style"
        }
    }
    
    public var encodedPrimaryText: String {
        return primaryText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? primaryText
    }
}

extension Meta.Entity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{\(range.debugDescription), \(primaryText), \(typeName)"
    }
}
