//
//  Meta.swift
//  
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import Foundation

public enum Meta {
    case url(_ text: String, trimmed: String, url: String, userInfo: [AnyHashable: Any]? = nil)
    case hashtag(_ text: String, hashtag: String, userInfo: [AnyHashable: Any]? = nil)
    case cashtag(_ text: String, cashtag: String, userInfo: [AnyHashable: Any]? = nil)
    case mention(_ text: String, mention: String, userInfo: [AnyHashable: Any]? = nil)
    case email(_ text: String, userInfo: [AnyHashable: Any]? = nil)
    case emoji(_ text: String, shortcode: String, url: String, userInfo: [AnyHashable: Any]? = nil)
}

extension Meta {

    public static func trim(content: String, orderedEntities: [Meta.Entity]) -> String {
        var content = content
        for entity in orderedEntities {
            Meta.trim(content: &content, entity: entity, entities: orderedEntities)
        }
        return content
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

        // workaround emoji count differnt in Swift issue
        let offset = (trimmed as NSString).length - (text as NSString).length
        entity.range.length += offset

        let moveEntities = Array(entities[index...].dropFirst())
        for moveEntity in moveEntities {
            moveEntity.range.location += offset
        }
    }
    
}

// MARK: - CustomDebugStringConvertible
extension Meta: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .url(let text, _, _, _):
            return text
        case .hashtag(let text, _, _):
            return text
        case .cashtag(let text, _, _):
            return text
        case .mention(let text, _, _):
            return text
        case .email(let text, _):
            return text
        case .emoji(let text, _, _, _):
            return text
        }
    }
}
