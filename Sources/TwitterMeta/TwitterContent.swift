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

    public init(
        content: String,
        urlEntities: [URLEntity]
    ) {
        self.content = content
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&apos;", with: "'")
        self.urlEntities = urlEntities
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
