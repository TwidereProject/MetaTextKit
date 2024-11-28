//
//  AnimatedImageMetaAttachmentViewProvider.swift
//  MetaTextKit
//
//  Created by MainasuK on 2024-11-28.
//

import os.log
import UIKit
import Combine
import UniformTypeIdentifiers
import SDWebImage

public class AnimatedImageMetaAttachmentViewProvider: NSTextAttachmentViewProvider {
    public override func loadView() {
        guard let textAttachment = textAttachment as? AnimatedImageMetaAttachment else { return }
        let attachmentView = AnimatedImageMetaAttachmentView(textAttachment: textAttachment)
        view = attachmentView
    }
}
