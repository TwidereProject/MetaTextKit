//
//  MetaTextView.swift
//  
//
//  Created by MainasuK Cirno on 2021-6-28.
//

import os.log
import UIKit
import Combine

public protocol MetaTextViewDelegate: AnyObject {
    func metaTextView(_ metaTextView: MetaTextView, didSelectLink link: URL)
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
        guard !isEditable else {
            return super.point(inside: point, with: event)
        }

        return link(at: point) != nil
    }

    func link(at point: CGPoint) -> URL? {
        guard let _ = linkDelegate else {
            return nil
        }

        let glyphIndex: Int? = layoutManager.glyphIndex(for: point, in: textContainer, fractionOfDistanceThroughGlyph: nil)
        let index: Int? = layoutManager.characterIndexForGlyph(at: glyphIndex ?? 0)

        if let characterIndex = index,
           characterIndex < textStorage.length,
           let link = textStorage.attribute(.link, at: characterIndex, effectiveRange: nil) as? URL
        {
            return link
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
            let point = sender.location(in: self)
            guard let link = link(at: point) else { return }
            linkDelegate?.metaTextView(self, didSelectLink: link)
        default:
            break
        }
    }
}
