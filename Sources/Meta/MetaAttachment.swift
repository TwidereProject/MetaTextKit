//
//  MetaAttachment.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-27.
//

import UIKit

public protocol MetaAttachmentDelegate: AnyObject {
    func metaAttachment(_ metaAttachment: MetaAttachment, imageUpdated image: UIImage)
}

public protocol MetaAttachment: NSTextAttachment {
    var delegate: MetaAttachmentDelegate? { get set }
    var string: String { get }
    var url: String { get }
}
