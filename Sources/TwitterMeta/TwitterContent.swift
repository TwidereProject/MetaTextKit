//
//  TwitterContnet.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import Foundation

public struct TwitterContent {
    public let content: String
    public let urlEntities: [URLEntity]
    public let richTextTags: [RichTextTag]

    public init(
        content: String,
        urlEntities: [URLEntity],
        richTextTags: [RichTextTag] = []
    ) {
        self.content = content
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
        self.urlEntities = urlEntities
        self.richTextTags = richTextTags
    }
}

extension TwitterContent {
    public struct URLEntity {
        public let url: String
        
        // optional
        public let expandedURL: String?
        public let displayURL: String?
        
        public init(
            url: String,
            expandedURL: String? = nil,
            displayURL: String? = nil
        ) {
            self.url = url
            self.expandedURL = expandedURL
            self.displayURL = displayURL
        }
    }
}

extension TwitterContent {
    public struct RichTextTag: Codable {
        public let range: NSRange
        public let types: [RichTextType]
        
        public init(range: NSRange, types: [RichTextType]) {
            self.range = range
            self.types = types
        }
    }
}

extension TwitterContent.RichTextTag {
    public enum RichTextType: RawRepresentable, Hashable, Codable {
        case bold
        case italic
        case _other(String)
        
        public init?(rawValue: String) {
            switch rawValue.lowercased() {
            case "bold":       self = .bold
            case "italic":     self = .italic
            default:           self = ._other(rawValue)
            }
        }
        
        public var rawValue: String {
            switch self {
            case .bold:                     return "Bold"
            case .italic:                   return "Italic"
            case ._other(let value):        return value
            }
        }
    }
}

extension TwitterContent.RichTextTag.RichTextType {
    public var metaStyleType: Meta.StyleType? {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case ._other:
            return nil
        }
    }
}
