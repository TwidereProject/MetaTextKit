//
//  TwitterContent+Meta.swift
//  
//
//  Created by MainasuK on 2023/5/31.
//

import Foundation

extension TwitterContent {
    /// Embed the input entities into content
    ///
    /// Use the method highlight known meta but meta's position changes
    /// For example, the translated content has the same meta (url, mention, hashtag…)
    /// but the position for meta changes in new language
    ///
    /// All short URLs will be replaced with the expanded one if `.urlEntities` not empty.
    ///
    /// - Parameter entities: entities for embed
    /// - Returns: meta content with embeded entities (ordered)
    public func embed(
        entities: [Meta.Entity],
        useParagraphMark: Bool = false
    ) -> TwitterMetaContent {
        var original = useParagraphMark ? content.replacingOccurrences(of: "\n+", with: "\u{2029}", options: .regularExpression) : content
        
        for urlEntity in urlEntities {
            guard let expandedURL = urlEntity.expandedURL else { continue }
            original = original.replacingOccurrences(of: urlEntity.url, with: expandedURL)
        }
        
        var newEntities: [Meta.Entity] = []
        let text = original as NSString
        
        for entity in entities {
            var searchRange = NSRange(location: 0, length: text.length)
            
            while searchRange.location < text.length {
                searchRange.length = text.length - searchRange.location
                let foundRange = text.range(of: entity.primaryText, range: searchRange)
                guard foundRange.location != NSNotFound else {
                    // break the inner while loop
                    break
                }
                
                let newEntity = Meta.Entity(range: foundRange, meta: entity.meta)
                newEntities.append(newEntity)
                
                searchRange.location = foundRange.location + foundRange.length
            }   // end while
        }   // end for … in …
        
        let orderedEntities = newEntities.sorted(by: {
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
