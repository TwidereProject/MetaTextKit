//
//  MetaLayoutManager.swift
//  
//
//  Created by MainasuK Cirno on 2021-7-22.
//

import UIKit
import Meta

// ref: https://github.com/lingochamp/FuriganaTextView/blob/master/src/FuriganaLayoutManager.swift
public class MetaLayoutManager: NSLayoutManager {

    static let displayAttachmentContentViewTag = 13626

    /// Label or TextView
    weak var hostView: UIView?

    public override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)

        guard let texStorage = textStorage else { return }

        var displayingAttachmentContentViews: [UIView] = []

        textStorage?.enumerateAttribute(
            .attachment,
            in: NSRange(location: 0, length: texStorage.length),
            options: .reverse)
        { attachment, range, canStop in
            guard let attachment = attachment as? MetaAttachment else {
                return
            }

            var frame = attachment.contentFrame
            frame.origin.y -= frame.height      // tweak frame
            attachment.content.frame = frame

            if attachment.content.superview == nil {
                attachment.content.tag = MetaLayoutManager.displayAttachmentContentViewTag
                hostView?.addSubview(attachment.content)
            }

            displayingAttachmentContentViews.append(attachment.content)
        }

        // remove attachment content when attachment deleted
        for view in hostView?.subviews ?? [] where view.tag == MetaLayoutManager.displayAttachmentContentViewTag {
            guard displayingAttachmentContentViews.contains(view) else {
                view.removeFromSuperview()
                continue
            }
        }
    }
}

