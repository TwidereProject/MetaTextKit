//
//  MetaLabel.swift
//  
//
//  Created by MainasuK Cirno on 2021-7-22.
//

import UIKit
import Meta

public class MetaLabel: UILabel {

    public let layoutManager = MetaLayoutManager()
    public let textStorage = MetaTextStorage()
    public let textContainer = NSTextContainer(size: .zero)

    public var textAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: MetaText.fontSize, weight: .regular)),
        .foregroundColor: UIColor.label,
        .paragraphStyle: MetaText.paragraphStyle,
    ]

    public var linkAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: MetaText.fontSize, weight: .semibold)),
        .foregroundColor: UIColor.link,
        .paragraphStyle: MetaText.paragraphStyle,
    ]


    public override init(frame: CGRect) {
        super.init(frame: frame)

        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        layoutManager.hostView = self

        isUserInteractionEnabled = true

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MetaLabel {


open override var intrinsicContentSize: CGSize {
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
