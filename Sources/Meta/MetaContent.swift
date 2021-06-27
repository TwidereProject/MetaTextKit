//
//  MetaContent.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-25.
//

import Foundation

public protocol MetaContent {
    var string: String { get }
    var entities: [Meta.Entity] { get }

    func metaAttachment(for entity: Meta.Entity) -> MetaAttachment?
}
