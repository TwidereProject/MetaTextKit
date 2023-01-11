//
//  PlaintextMetaContent.swift
//  
//
//  Created by MainasuK on 2022-8-4.
//

import Foundation

public struct PlaintextMetaContent: MetaContent {
    public let string: String
    public let entities: [Meta.Entity] = []
    
    public init(string: String) {
        self.string = string
    }
    
    public func metaAttachment(for entity: Meta.Entity, useTextKit2: Bool) -> MetaAttachment? {
        return nil
    }
}
