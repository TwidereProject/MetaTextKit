//
//  TwitterMetaContent.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import Foundation
import Meta
import SDWebImage

public struct TwitterMetaContent {
    public let original: String
    public let trimmed: String

    public var entities: [Meta.Entity]
}

extension TwitterMetaContent: MetaContent {
    public var string: String { trimmed }

    public func metaAttachment(for entity: Meta.Entity) -> MetaAttachment? {
        switch entity.meta {
        case .icon(let text, let url, _):
            let imageView = SDAnimatedImageView()
            let attachment = AnimatedImageMetaAttachment(string: text, url: url, content: imageView)
            return attachment
        default:
            return nil
        }
    }
}
