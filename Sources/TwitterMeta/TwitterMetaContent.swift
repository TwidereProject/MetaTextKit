//
//  TwitterMetaContent.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import Foundation
import Meta

public struct TwitterMetaContent {
    public let original: String
    public let trimmed: String

    public var entities: [Meta.Entity]
}

extension TwitterMetaContent: MetaContent {
    public var string: String { trimmed }
    public func metaAttachment(for entity: Meta.Entity) -> MetaAttachment? {
        return nil
    }
}
