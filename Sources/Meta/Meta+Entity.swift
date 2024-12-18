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
    public var text: String {
        switch self.meta {
        case .url(let text, _, _, _):           return text
        case .emoji(let text, _, _, _):         return text
        case .hashtag(let text, _, _):          return text
        case .cashtag(let text, _, _):          return text
        case .mention(let text, _, _):          return text
        case .email(let text, _):               return text
        case .icon(let text, _, _):             return text
        case .media(let text, _, _):            return text
        case .style(let text, _, _):            return text
        }
    }

    public var primaryText: String {
        switch self.meta {
        case .url(_, _, let url, _):            return url
        case .emoji(let text, _, _, _):         return text
        case .hashtag(let text, _, _):          return text
        case .cashtag(let text, _, _):          return text
        case .mention(let text, _, _):          return text
        case .email(let text, _):               return text
        case .icon(let text, _, _):             return text
        case .media(let text, _, _):            return text
        case .style(let text, _, _):            return text
        }
    }

    public var trimmed: String {
        switch self.meta {
        case .url(_, let trimmed, _, _):
            return trimmed
        default:
            guard let trimmed = userInfo?["_trimmed"] as? String else {
                return text
            }
            return trimmed
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
        case .icon: return "icon"
        case .media: return "media"
        case .style: return "style"
        }
    }

    public var userInfo: [AnyHashable: Any]? {
        switch self.meta {
        case .url(_, _, _, let userInfo):           return userInfo
        case .emoji(_, _, _, let userInfo):         return userInfo
        case .hashtag(_, _, let userInfo):          return userInfo
        case .cashtag(_, _, let userInfo):          return userInfo
        case .mention(_, _, let userInfo):          return userInfo
        case .email(_, let userInfo):               return userInfo
        case .icon(_, _, let userInfo):             return userInfo
        case .media(_, _, let userInfo):            return userInfo
        case .style(_, _, let userInfo):            return userInfo
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
