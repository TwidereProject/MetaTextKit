//
//  MediaMetaAttachmentViewProvider.swift
//  MetaTextKit
//
//  Created by MainasuK on 2024-12-17.
//

import os.log
import UIKit
import Combine
import UniformTypeIdentifiers
import SDWebImage

public class MediaMetaAttachmentViewProvider: NSTextAttachmentViewProvider {
    public override func loadView() {
        guard let textAttachment = textAttachment as? MediaMetaAttachment else { return }
        let attachmentView = MediaMetaAttachmentView(textAttachment: textAttachment)
        view = attachmentView
    }

    public override func attachmentBounds(
        for attributes: [NSAttributedString.Key : Any],
        location: any NSTextLocation,
        textContainer: NSTextContainer?,
        proposedLineFragment: CGRect,
        position: CGPoint
    ) -> CGRect {
        let width = proposedLineFragment.width
        let height: CGFloat = {
            guard let attachment = attributes[.attachment] as? MediaMetaAttachment else {
                return 200
            }
            let size = attachment.size
            guard size.width > 0, size.height > 0 else {
                return 200
            }
            let height = width / size.width * size.height
            return height
        }()
        return CGRect(x: 0, y: 0, width: proposedLineFragment.width, height: height)
    }
}
