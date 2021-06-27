//
//  Meta+Mastodon.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-25.
//

import Foundation

public struct MastodonContent {
    public typealias Shortcode = String
    public typealias Emojis = [Shortcode: String]
    
    public let content: String
    public let emojis: Emojis

    public init(content: String, emojis: [MastodonContent.Shortcode: String]) {
        self.content = content
        self.emojis = emojis
    }
}
