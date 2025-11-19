//
//  MetaTextView.swift
//  
//
//  Created by MainasuK Cirno on 2021-6-28.
//

import os.log
import UIKit
import Combine
import Meta

public protocol MetaTextViewDelegate: AnyObject {
    func metaTextView(_ metaTextView: MetaTextView, didSelectMeta meta: Meta)
}

public class MetaTextView: UITextView {

    public weak var linkDelegate: MetaTextViewDelegate?

    let tapGestureRecognizer = UITapGestureRecognizer()

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        _init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

//    public override var isEditable: Bool {
//        didSet {
//            tapGestureRecognizer.isEnabled = !isEditable
//        }
//    }

    private func _init() {
        addGestureRecognizer(tapGestureRecognizer)

        tapGestureRecognizer.addTarget(self, action: #selector(MetaTextView.tapGestureRecognizerHandler(_:)))
        tapGestureRecognizer.delaysTouchesBegan = false
        tapGestureRecognizer.isEnabled = true // !isEditable
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isEditable || isSelectable {
            return super.point(inside: point, with: event)
        }

        return meta(at: point) != nil
    }

    func meta(at point: CGPoint) -> Meta? {
        guard let _ = linkDelegate else {
            return nil
        }

        let glyphIndex: Int? = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        let index: Int? = layoutManager.characterIndexForGlyph(at: glyphIndex ?? 0)

        guard let characterIndex = index,
           characterIndex < textStorage.length
        else {
            return nil
        }

        if let meta = textStorage.attribute(.meta, at: characterIndex, effectiveRange: nil) as? Meta {
            return meta
        } else {
            var attachments: [MetaTextViewTextAttachment] = []
            var ranges: [NSRange] = []
            textStorage.enumerateAttributes(
                in: NSRange(location: 0, length: textStorage.length),
                options: NSAttributedString.EnumerationOptions(rawValue: 0)
            ) { (object, range, stop) in
                if let attachment = object[.attachment] as? MetaTextViewTextAttachment,
                   let _ = attachment.image
                {
                    attachments.append(attachment)
                    ranges.append(range)
                }
            }

            var fixPoint = point
            fixPoint.x -= self.textContainerInset.left
            fixPoint.y -= self.textContainerInset.top

            for (attachment, range) in zip(attachments, ranges) {
                let frameForAttachment = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)
                if frameForAttachment.contains(fixPoint) {
                    return Meta.mention("", mention: "", userInfo: attachment.userInfo)
                }
            }
        }

        return nil
    }

}

extension MetaTextView {
    @objc private func tapGestureRecognizerHandler(_ sender: UITapGestureRecognizer) {
        os_log(.info, "%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)

        switch sender.state {
        case .ended:
            // always try cancel selection when tap ended
            if isSelectable {
                selectedTextRange = nil
            }

            let point = sender.location(in: self)
            guard let meta = meta(at: point) else { return }
            linkDelegate?.metaTextView(self, didSelectMeta: meta)
        default:
            break
        }
    }
}

public class MetaTextViewTextAttachment: NSTextAttachment {
    public var userInfo: [String: Any]?
}
