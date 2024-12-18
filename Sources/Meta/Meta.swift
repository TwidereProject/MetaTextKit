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
    case icon(_ text: String, url: String, userInfo: [AnyHashable: Any]? = nil)
    case media(_ text: String, url: String, userInfo: [AnyHashable: Any]? = nil)
    case style(_ text: String, styles: [Meta.StyleType], userInfo: [AnyHashable: Any]? = nil)
}

#if DEBUG
extension Meta {
    public static var isDebugMode = false
}
#endif

extension Meta {
    public enum StyleType {
        case bold
        case italic
        case underline
    }
}

extension Meta {
    public static func trim(content: String, orderedEntities: [Meta.Entity]) -> String {
        var content = content
        for entity in orderedEntities {
            Meta.trim(content: &content, entity: entity, entities: orderedEntities)
        }
        return content
    }

    private static func trim(content: inout String, entity: Meta.Entity, entities: [Meta.Entity]) {
        let trimmed: String
        switch entity.meta {
        case .url(_, let _trimmed, _, _):
            trimmed = _trimmed
        case .emoji:
            trimmed = " "
        default:
            guard let userInfo = entity.userInfo, let _trimmed = userInfo["_trimmed"] as? String else {
                return
            }
            trimmed = _trimmed
        }

        guard let index = entities.firstIndex(where: { $0.range == entity.range }) else { return }
        guard let range = Range(entity.range, in: content) else { return }
        content.replaceSubrange(range, with: trimmed)

        // workaround emoji count differnt in Swift issue
        let offset = (trimmed as NSString).length - entity.range.length
        entity.range.length += offset

        let moveEntities = Array(entities[index...].dropFirst())
        for moveEntity in moveEntities {
            moveEntity.range.location += offset
        }
    }
}

extension Meta {

    public static func replaceParagraphMark(content: String, orderedEntities: [Meta.Entity]) -> String {
        var content = content
        var orderedEntities = orderedEntities
        do {
            let regex = try NSRegularExpression(pattern: #"\n+"#, options: [])
            let range = NSRange(content.startIndex..<content.endIndex, in: content)
            let matchResults = regex.matches(in: content, options: [], range: range)
            for match in matchResults {
                guard let substring = content.substring(in: match) else { continue }
                let text = String(substring)
                let meta: Meta = .url(text, trimmed: "\u{2029}", url: text, userInfo: ["type":"ParagraphMarkEntity"])
                orderedEntities.append(Meta.Entity(range: match.range, meta: meta))
            }
        } catch {
            assertionFailure()
        }
        orderedEntities = orderedEntities.sorted(by: { $0.range.location < $1.range.location })
        
        for entity in orderedEntities {
            Meta.trim(content: &content, entity: entity, entities: orderedEntities)
        }
        return content
    }

    private static func replaceParagraphMark(content: inout String, entity: Meta.Entity, entities: [Meta.Entity]) {
        let trimmed: String
        switch entity.meta {
        case .url(_, let _trimmed, _, let userInfo) where (userInfo?["type"] as? String) == "ParagraphMarkEntitys":
            trimmed = _trimmed
        default:
            return
        }

        guard let index = entities.firstIndex(where: { $0.range == entity.range }) else { return }
        guard let range = Range(entity.range, in: content) else { return }
        content.replaceSubrange(range, with: trimmed)

        // workaround emoji count differnt in Swift issue
        let offset = (trimmed as NSString).length - entity.range.length
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
        case .icon(let text, _, _):
            return text
        case .media(let text, _, _):
            return text
        case .style(let text, _, _):
            return text
        }
    }
}

extension String {
    func substring(in match: NSTextCheckingResult, at index: Int = 0) -> Substring? {
        guard index < match.numberOfRanges else { return nil }
        let targetNSRange = match.range(at: index)
        guard targetNSRange.location != NSNotFound else { return nil }
        guard let targetRange = Range(targetNSRange, in: self) else { return nil }
        let substring = self[targetRange]
        return substring
    }
}
