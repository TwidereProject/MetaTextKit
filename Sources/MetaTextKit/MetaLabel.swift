//
//  MetaLabel.swift
//  
//
//  Created by MainasuK Cirno on 2021-7-22.
//

import os.log
import UIKit
import Meta

public protocol MetaLabelDelegate: AnyObject {
    func metaLabel(_ metaLabel: MetaLabel, didSelectMeta meta: Meta)
}

public class MetaLabel: UILabel {

    public weak var linkDelegate: MetaLabelDelegate?

    public let layoutManager = MetaLayoutManager()
    public let textStorage = MetaTextStorage()
    public let textContainer = NSTextContainer(size: .zero)

    public var paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 8
        return style
    }()

    public var textAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: MetaText.fontSize, weight: .regular)),
        .foregroundColor: UIColor.label,
    ]

    public var linkAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: MetaText.fontSize, weight: .semibold)),
        .foregroundColor: UIColor.link,
    ]

    let tapGestureRecognizer = UITapGestureRecognizer()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.hostView = self

        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)

        tapGestureRecognizer.addTarget(self, action: #selector(MetaLabel.tapGestureRecognizerHandler(_:)))
        tapGestureRecognizer.delaysTouchesBegan = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension MetaLabel {
    @objc private func tapGestureRecognizerHandler(_ sender: UITapGestureRecognizer) {
        os_log(.info, "%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)

        switch sender.state {
        case .ended:
            let point = sender.location(in: self)
            guard let meta = meta(at: point) else { return }
            linkDelegate?.metaLabel(self, didSelectMeta: meta)
        default:
            break
        }
    }
}

extension MetaLabel {

    public override var intrinsicContentSize: CGSize {
        textContainer.size = CGSize(width: self.preferredMaxLayoutWidth, height: CGFloat.greatestFiniteMagnitude)
        let size = layoutManager.usedRect(for: textContainer)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }

    public override func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)

        let origin: CGPoint = .zero
        layoutManager.drawBackground(forGlyphRange: range, at: origin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: origin)
    }

}

extension MetaLabel {
    public func configure(content: MetaContent) {
        let attributedString = NSMutableAttributedString(string: content.string)

        MetaText.setAttributes(
            for: attributedString,
            textAttributes: textAttributes,
            linkAttributes: linkAttributes,
            paragraphStyle: paragraphStyle,
            content: content
        )

        textStorage.setAttributedString(attributedString)
        self.attributedText = attributedString
        setNeedsDisplay()
    }

    public func reset() {
        let attributedString = NSAttributedString(string: "")
        textStorage.setAttributedString(attributedString)
        self.attributedText = attributedString
        setNeedsDisplay()
    }

}
