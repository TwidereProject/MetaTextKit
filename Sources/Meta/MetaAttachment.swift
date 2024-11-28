//
//  MetaAttachment.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-27.
//

import UIKit

public protocol MetaAttachment: NSTextAttachment {
    var string: String { get }
    var url: String { get }
    var content: UIView { get }
    var contentFrame: CGRect { get set }
    var viewProvider: NSTextAttachmentViewProvider? { get }
}
