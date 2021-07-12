//
//  MetaText.swift
//
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit
import Meta

public protocol MetaTextDelegate: AnyObject {
    func metaText(_ metaText: MetaText, processEditing textStorage: MetaTextStorage) -> MetaContent?
}

public class MetaText: NSObject {

    public weak var delegate: MetaTextDelegate?
    
    public let textStorage: MetaTextStorage
    public let textView: MetaTextView

    static var fontSize: CGFloat = 17

    static var paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 8
        return style
    }()

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
    
    public override init() {
        let textStorage = MetaTextStorage()
        self.textStorage = textStorage

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: .zero)
        layoutManager.addTextContainer(textContainer)

        textView = MetaTextView(frame: .zero, textContainer: textContainer)

        super.init()

        textStorage.processDelegate = self
        layoutManager.delegate = self
    }
    
}

extension MetaText {

    open var backedString: String {
        let string = textStorage.string
        let nsString = NSMutableString(string: string)
        textStorage.enumerateAttribute(
            .attachment,
            in: NSRange(location: 0, length: textStorage.length),
            options: [.reverse])
        { value, range, _ in
            guard let attachment = value as? MetaAttachment else { return }
            nsString.replaceCharacters(in: range, with: attachment.string)
        }
        return nsString as String
    }

}

extension MetaText {

    public func configure(content: MetaContent) {
        let attributedString = NSMutableAttributedString(string: content.string)

        let attachments = MetaText.setAttributes(
            for: attributedString,
            textAttributes: textAttributes,
            linkAttributes: linkAttributes,
            content: content
        )

        textView.linkTextAttributes = linkAttributes
        textView.attributedText = attributedString

        for attachment in attachments {
            attachment.delegate = self
        }
    }

}

// MARK: - MetaAttachmentDelegate
extension MetaText: MetaAttachmentDelegate {
    public func metaAttachment(_ metaAttachment: MetaAttachment, imageUpdated image: UIImage) {
        // not locate range for attachment to profile batch of emoji loading performance (> 100)
        textView.setNeedsDisplay()
    }
}

// MARK: - MetaTextStorageDelegate
extension MetaText: MetaTextStorageDelegate {
    open func processEditing(_ textStorage: MetaTextStorage) -> MetaContent? {
        guard let content = delegate?.metaText(self, processEditing: textStorage) else { return nil }

        // configure meta
        textStorage.beginEditing()
        let attachments = MetaText.setAttributes(
            for: textStorage,
            textAttributes: textAttributes,
            linkAttributes: linkAttributes,
            content: content
        )
        textStorage.endEditing()

        for attachment in attachments {
            attachment.delegate = self
        }

        return content
    }
}

extension MetaText {
    public static func setAttributes(
        for attributedString: NSMutableAttributedString,
        textAttributes: [NSAttributedString.Key: Any],
        linkAttributes: [NSAttributedString.Key: Any],
        content: MetaContent
    ) -> [MetaAttachment] {
        // clean up
        let allRange = NSRange(location: 0, length: attributedString.length)
        for key in textAttributes.keys {
            attributedString.removeAttribute(key, range: allRange)
        }
        for key in linkAttributes.keys {
            attributedString.removeAttribute(key, range: allRange)
        }
        attributedString.removeAttribute(.link, range: allRange)

        // setup
        attributedString.addAttributes(
            textAttributes,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        for entity in content.entities {
            if let uri = entity.meta.uri {
                var linkAttributes = linkAttributes
                linkAttributes[.link] = uri
                attributedString.addAttributes(linkAttributes, range: entity.range)
            }
        }

        var replacedAttachments: [MetaAttachment] = []
        for entity in content.entities.reversed() {
            guard let attachment = content.metaAttachment(for: entity) else { continue }
            replacedAttachments.append(attachment)

            let font = attributedString.attribute(.font, at: entity.range.location, effectiveRange: nil) as? UIFont
            let fontSize = font?.pointSize ?? MetaText.fontSize
            attachment.bounds = CGRect(
                origin: CGPoint(x: 0, y: -floor(fontSize / 6)),  // magic
                size: CGSize(width: fontSize, height: fontSize)
            )

            attributedString.replaceCharacters(in: entity.range, with: NSAttributedString(attachment: attachment))
        }

        return replacedAttachments
    }
}


extension NSAttributedString.Key {
    public static let metaEmojiText = NSAttributedString.Key(rawValue: "MetaEmojiTextKey")
}
