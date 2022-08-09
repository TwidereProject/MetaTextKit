//
//  MetaLabel.swift
//  
//
//  Created by MainasuK Cirno on 2021-7-22.
//

import os.log
import UIKit
import Meta
import MetaTextKit
import MetaTextArea

public protocol MetaLabelDelegate: AnyObject {
    func metaLabel(_ metaLabel: MetaLabel, didSelectMeta meta: Meta)
}

public class MetaLabel: UIView {

    static var fontSize: CGFloat = 17

    public weak var delegate: MetaLabelDelegate?
    
    public let textArea = MetaTextAreaView()

    public var paragraphStyle: NSMutableParagraphStyle {
        get { textArea.paragraphStyle }
        set { textArea.paragraphStyle = newValue }
    }

    public var textAttributes: [NSAttributedString.Key: Any] {
        get { textArea.textAttributes }
        set { textArea.textAttributes = newValue }
    }

    public var linkAttributes: [NSAttributedString.Key: Any] {
        get { textArea.linkAttributes }
        set { textArea.linkAttributes = newValue }
    }

    let tapGestureRecognizer = UITapGestureRecognizer()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        textArea.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textArea)
        NSLayoutConstraint.activate([
            textArea.topAnchor.constraint(equalTo: topAnchor),
            textArea.leadingAnchor.constraint(equalTo: leadingAnchor),
            textArea.trailingAnchor.constraint(equalTo: trailingAnchor),
            textArea.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        textArea.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        textArea.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        textArea.textContainer.lineBreakMode = .byTruncatingTail
        textArea.textContainer.maximumNumberOfLines = 1
        textArea.textContainer.lineFragmentPadding = 0
        textArea.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MetaLabel {

    public override var intrinsicContentSize: CGSize {
        // calculate size
        var size: CGSize = .zero
        textArea.textLayoutManager.textContainer?.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textArea.textLayoutManager.enumerateTextLayoutFragments(
            from: textArea.textLayoutManager.documentRange.endLocation,
            options: [.ensuresLayout, .reverse]
        ) { layoutFragment in
            // prefer glyph bounds
            size = layoutFragment.textLineFragments.first?.typographicBounds.size ?? layoutFragment.layoutFragmentFrame.size
            return false // stop
        }
        return CGSize(
            width: ceil(size.width),
            height: ceil(size.height)
        )
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
        
        textArea.configure(content: content)
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }

    public func reset() {
        textArea.configure(content: PlaintextMetaContent(string: ""))
        setNeedsDisplay()
    }

}

// MARK: - MetaTextAreaViewDelegate
extension MetaLabel: MetaTextAreaViewDelegate {
    public func metaTextAreaView(_ metaTextAreaView: MetaTextArea.MetaTextAreaView, didSelectMeta meta: Meta) {
        delegate?.metaLabel(self, didSelectMeta: meta)
    }
}
