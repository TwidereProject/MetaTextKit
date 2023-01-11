//
//  MastodonMetaContent.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-25.
//

import Foundation
import Meta
import Alamofire
import SDWebImage

/// Generic Mastodon status content
///
/// - usage:
///   ```
///   // For document content from server
///   let content = MastodonContent(content: status.content, status.emojis)
///   let metaContent = MastodonMetaContent.convert(from: content)
///
///   // For text content from text editor
///   ```
public struct MastodonMetaContent {
    public let document: String
    public let original: String
    public let trimmed: String

    public let entities: [Meta.Entity]
}

extension MastodonMetaContent: MetaContent {
    public var string: String { trimmed }

    public func metaAttachment(for entity: Meta.Entity, useTextKit2: Bool) -> MetaAttachment? {
        guard case let .emoji(text, _, url, _) = entity.meta else { return nil }

        let imageView = SDAnimatedImageView()
        if useTextKit2 {
            return MastodonMetaAttachmentTextKit2(string: text, url: url, content: imageView)
        }
        return MastodonMetaAttachmentTextKit1(string: text, url: url, content: imageView)
    }
}

