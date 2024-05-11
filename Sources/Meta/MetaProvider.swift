//
//  MetaContentProvider.swift
//
//
//  Created by MainasuK on 2024-05-11.
//

import Foundation

public protocol MetaProvider {
    /// Returns customized meta entity for given content
    /// - Parameters:
    ///   - content: the text content
    ///   - entities: meta entities parsed from this package
    /// - Returns: addtional meta entities from this provider
    /// - Note: the overlaped meta entities will be filter out
    func parse(content: String, entities: [Meta.Entity]) -> [Meta.Entity]
}
