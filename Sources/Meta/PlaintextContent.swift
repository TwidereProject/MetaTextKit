//
//  PlaintextContent.swift
//  MetaTextKit
//
//  Created by MainasuK on 2024-11-28.
//

import Foundation

public struct PlaintextContent: RawContent {
    public var content: String

    public init(content: String) {
        self.content = content
    }
}
