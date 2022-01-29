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
    
    public static var normalRedactedTextColor = UIColor.systemGray6
    public static var highlightRedactedTextColor = UIColor(red: 242.0/255.0, green: 248.0/255.0, blue: 253.0/255.0, alpha: 1.0)

    /// Label or TextView
    weak var hostView: UIView?
        
    public var isRedactedModeEnabled = false

    public override func drawGlyphs(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        if !isRedactedModeEnabled {
            super.drawGlyphs(forGlyphRange: glyphsToShow, at: origin)
        }
        
        guard let textStorage = textStorage else { return }
        var displayingAttachmentContentViews: [UIView] = []

        if isRedactedModeEnabled {
            let text = textStorage.string as NSString
            if let context = UIGraphicsGetCurrentContext(),
               let textContainer = textContainer(forGlyphAt: glyphsToShow.location, effectiveRange: nil)
            {
                // draw redacted style text
                UIGraphicsPushContext(context)
                
                for index in 0..<glyphsToShow.length {
                    let location = index + glyphsToShow.location
                    let glyphRange = NSRange(location: location, length: 1)
                    let glyph = text.substring(with: glyphRange)
                    let characterSet = CharacterSet.whitespacesAndNewlines
                    guard glyph.rangeOfCharacter(from: characterSet) == nil else {
                        continue
                    }
                    let _rect = boundingRect(forGlyphRange: glyphRange, in: textContainer)
                        .inset(by: UIEdgeInsets(top: 2, left: -1, bottom: 2, right: -1))
                        .standardized
                    
                    // try anti-aliasing
                    let rect = CGRect(
                        origin: CGPoint(x: floor(_rect.origin.x), y: floor(_rect.origin.y)),
                        size: CGSize(width: ceil(_rect.width), height: ceil(_rect.height))
                    )
                    let attributes = textStorage.attributes(at: location, effectiveRange: nil)
                    if attributes[.meta] != nil {
                        context.setFillColor(MetaLayoutManager.highlightRedactedTextColor.cgColor)
                    } else {
                        context.setFillColor(MetaLayoutManager.normalRedactedTextColor.cgColor)
                    }
                    context.fill(rect)
                }
                UIGraphicsPopContext()
            }
        } else {
            // layout attachment
            textStorage.enumerateAttribute(
                .attachment,
                in: NSRange(location: 0, length: textStorage.length),
                options: .reverse
            ) { attachment, range, canStop in
                guard let attachment = attachment as? MetaAttachment else {
                    return
                }

                var frame = attachment.contentFrame
                frame.origin.y -= frame.height      // tweak frame
                if frame.origin.x == 0 {
                    // attachment user interact (a.k.a long press) cause origin.x set to ZERO with wrong origin.y
                    // which cause the wrong image view position
                    // check it and locate to correct location here
                    let glyphRange = glyphRange(forCharacterRange: range, actualCharacterRange: nil)
                    if let textContainer = textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) {
                        let glyphBounds = boundingRect(forGlyphRange: glyphRange, in: textContainer)
                        frame.origin.x = glyphBounds.origin.x
                        let textViewPadding: CGFloat = {
                            var padding = textContainer.lineFragmentPadding
                            guard let textView = hostView as? UITextView else { return padding }
                            padding += textView.contentInset.top
                            return padding
                        }()
                        frame.origin.y = glyphBounds.origin.y + textViewPadding
                    }
                }
                attachment.content.frame = frame

                if attachment.content.superview == nil {
                    attachment.content.tag = MetaLayoutManager.displayAttachmentContentViewTag
                    hostView?.addSubview(attachment.content)
                }

                displayingAttachmentContentViews.append(attachment.content)
            }
        }   // end if isRedactedMode { … } else { … }

        // remove attachment content when attachment deleted
        for view in hostView?.subviews ?? [] where view.tag == MetaLayoutManager.displayAttachmentContentViewTag {
            guard displayingAttachmentContentViews.contains(view) else {
                view.removeFromSuperview()
                continue
            }
        }
    }   // end func drawGlyphs
}

