//
//  InlineIconMetaProvider.swift
//  iOS Example
//
//  Created by MainasuK on 2024-11-28.
//  Copyright © 2024 MetaTextKit. All rights reserved.
//

import Foundation
import Meta

struct InlineIconMetaProvider {
    public let option: Option
    public let context: Context

    public init(
        option: Option,
        context: Context
    ) {
        self.option = option
        self.context = context
    }
}

extension InlineIconMetaProvider {
    public struct Option: OptionSet {

        public let rawValue: Int

        // abc, efg
        public static let keyword = Option(rawValue: 1 << 0)

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static var `all`: Option = [.keyword]
    }

    public struct Context {
        let dict: [String: URL]
    }
}
extension InlineIconMetaProvider {
    private static func parseKeywoard(
        from content: String,
        keyword: String,
        iconURL: URL
    ) -> [Meta.Entity] {
        let regex = try! NSRegularExpression(
            pattern: #"(?<keyword>(\#(keyword)))"#,
            options: []
        )
        let range = NSRange(content.startIndex..<content.endIndex, in: content)
        let matches = regex.matches(in: content, range: range)

        var entities: [Meta.Entity] = []
        for match in matches {
            let rangeOfKeyword = match.range(withName: "keyword")
            guard rangeOfKeyword.location != NSNotFound else { continue }
            let text = content.substring(with: rangeOfKeyword)

            let string = ""
            let stringRange = NSRange(location: rangeOfKeyword.location, length: (string as NSString).length)
            let url = iconURL
            let userInfo: [AnyHashable : Any] = [
                "provider": String(describing: InlineIconMetaProvider.self),
                "keyword": keyword
            ]
            let entity = Meta.Entity(
                range: stringRange,
                meta: .icon(text, url: url.absoluteString, userInfo: userInfo)
            )
            entities.append(entity)
        }
        return entities
    }
}

// MARK: - MetaProvider
extension InlineIconMetaProvider: MetaProvider {
    func parse(
        content: String,
        entities: [Meta.Entity]
    ) -> [Meta.Entity] {
        var result: [Meta.Entity] = []

        // keyword
        if option.contains(.keyword) {
            for (keyword, iconURL) in context.dict {
                let newEntities = InlineIconMetaProvider.parseKeywoard(
                    from: content,
                    keyword: keyword,
                    iconURL: iconURL
                )
                result.append(contentsOf: newEntities)
            }
        }

        return result
    }
}

extension String {
    @inlinable
    public func substring(with range: NSRange) -> String {
        (self as NSString).substring(with: range)
    }
}
