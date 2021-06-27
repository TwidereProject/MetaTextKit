//
//  MastodonMetaContent+Text.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-26.
//

import Foundation
import Meta

extension MastodonMetaContent {

    enum Symbol: CaseIterable {
        case emoji
        case hashtag
        case mention

        var prefix: String {
            switch self {
            case .emoji:        return ":"
            case .hashtag:      return "#"
            case .mention:      return "@"
            }
        }

        static let prefixCharacterSet: CharacterSet = {
            let prefixes = Symbol.allCases.map { $0.prefix }.joined()
            return CharacterSet(charactersIn: prefixes)
        }()
    }

    struct Regex {
        lazy var emojiRegex = try? NSRegularExpression(pattern: #"(?:([a-zA-Z0-9_]+)(:\B(?=\s)))"#, options: [])
        lazy var hashtagRegex = try? NSRegularExpression(pattern: #"(?:([^\s.]+))"#, options: [])
        lazy var mentionRegex = try? NSRegularExpression(pattern: #"(?:([a-zA-Z0-9_]+)(@[a-zA-Z0-9_.-]+)?)"#, options: [])
    }

    static var regex = Regex()

    public static func convert(text content: MastodonContent) -> MastodonMetaContent {
        // find http/https link
        var linkEnitties: [Meta.Entity] = []
        do {
            let regex = try NSRegularExpression(pattern: #"(?i)https?://\S+(?:/|\b)"#, options: [])
            let range = NSRange(content.content.startIndex..<content.content.endIndex, in: content.content)
            let matchResults = regex.matches(in: content.content, options: [], range: range)
            for match in matchResults {
                guard let substring = content.content.substring(in: match) else { continue }
                let text = String(substring)
                let meta: Meta = .url(text, trimmed: text, url: text, userInfo: [:])
                linkEnitties.append(Meta.Entity(range: match.range, meta: meta))
            }
        } catch {
            assertionFailure()
        }

        guard let emojiRegex = regex.emojiRegex,
              let hashtagRegex = regex.hashtagRegex,
              let mentionRegex = regex.mentionRegex else {
            assertionFailure()
            return MastodonMetaContent(
                document: content.content,
                original: content.content,
                trimmed: content.content,
                entities: linkEnitties
            )
        }

        // find symbol
        var symbolEntities: [Meta.Entity] = []

        let scanner = Scanner(string: content.content)
        scanner.caseSensitive = false

        // while hasMoreSymbol
        while !scanner.isAtEnd {
            _ = scanner.scanUpToCharacters(from: Symbol.prefixCharacterSet)
            if scanner.scanString(Symbol.emoji.prefix) != nil {
                let range = NSRange(scanner.currentIndex..<scanner.string.endIndex, in: scanner.string)
                if let match = emojiRegex.firstMatch(in: scanner.string, options: [], range: range),
                      let text = scanner.string.substring(in: match, at: 0),
                      text.startIndex == scanner.currentIndex,
                      let shortcode = scanner.string.substring(in: match, at: 1),
                      let url = content.emojis[String(shortcode)]
                {
                    let string = ":\(shortcode):"
                    let meta: Meta = .emoji(string, shortcode: String(shortcode), url: url, userInfo: nil)
                    _ = scanner.scanString(String(text))
                    let length = (string as NSString).length
                    let stringRange = NSRange(location: range.location - 1, length: length)
                    symbolEntities.append(Meta.Entity(range: stringRange, meta: meta))
                }
            } else if scanner.scanString(Symbol.hashtag.prefix) != nil {
                let range = NSRange(scanner.currentIndex..<scanner.string.endIndex, in: scanner.string)
                if let match = hashtagRegex.firstMatch(in: scanner.string, options: [], range: range),
                   let text = scanner.string.substring(in: match, at: 0),
                   text.startIndex == scanner.currentIndex,
                   let hashtag = scanner.string.substring(in: match, at: 1)
                {
                    let string = "#\(hashtag)"
                    let meta: Meta = .hashtag(string, hashtag: String(hashtag), userInfo: nil)
                    let stringRange = NSRange(location: range.location - 1, length: (string as NSString).length)
                    symbolEntities.append(Meta.Entity(range: stringRange, meta: meta))
                    _ = scanner.scanString(String(text))
                }
            } else if scanner.scanString(Symbol.mention.prefix) != nil {
                let range = NSRange(scanner.currentIndex..<scanner.string.endIndex, in: scanner.string)
                if let match = mentionRegex.firstMatch(in: scanner.string, options: [], range: range),
                   let text = scanner.string.substring(in: match, at: 0),
                   text.startIndex == scanner.currentIndex
                {
                    let string = "@\(text)"
                    let meta: Meta = .mention(string, mention: String(text), userInfo: nil)
                    let textRange = NSRange(location: range.location - 1, length: (string as NSString).length)
                    let stringRange = NSRange(location: textRange.location - 1, length: textRange.length + 1)
                    symbolEntities.append(Meta.Entity(range: stringRange, meta: meta))
                    _ = scanner.scanString(String(text))
                }
            } else {
                continue
            }
        }

        var entities = linkEnitties + symbolEntities
        entities.sort(by: { lhs, rhs in lhs.range.location < rhs.range.location })

        return MastodonMetaContent(
            document: content.content,
            original: content.content,
            trimmed: content.content,
            entities: entities
        )
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
