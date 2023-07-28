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

    public override var isEditable: Bool {
        didSet {
            tapGestureRecognizer.isEnabled = !isEditable
        }
    }

    private func _init() {
        addGestureRecognizer(tapGestureRecognizer)

        tapGestureRecognizer.addTarget(self, action: #selector(MetaTextView.tapGestureRecognizerHandler(_:)))
        tapGestureRecognizer.delaysTouchesBegan = false
        tapGestureRecognizer.isEnabled = !isEditable
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

        if let characterIndex = index,
           characterIndex < textStorage.length,
           let meta = textStorage.attribute(.meta, at: characterIndex, effectiveRange: nil) as? Meta
        {
            return meta
        } else {
            return nil
        }
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
    
    public override func copy(_ sender: Any?) {
        super.copy(sender)
        
        // escape the text layout mark
        // maybe rich text copy supports
        if let text = UIPasteboard.general.string {
            let result = text
                .replacingOccurrences(of: "\u{2028}", with: "\n")
                .replacingOccurrences(of: "\u{2029}", with: "\n")
            UIPasteboard.general.string = result
        }
    }
}
