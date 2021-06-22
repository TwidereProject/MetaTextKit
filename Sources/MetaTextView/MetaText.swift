//
//  MetaText.swift
//
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit
import Combine

open class MetaText: NSObject {
    
    public let textStorage: NSTextStorage
    public let textView: UITextView

    var entities: [Meta.Entity] = []
    private var emojiAttachments: [MetaTextAttribute.EmojiAttachment] = []
    
    public override init() {
        let textStorage = MetaTextStorage()
        self.textStorage = textStorage
        
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: .zero)
        layoutManager.addTextContainer(textContainer)
        
        textView = UITextView(frame: .zero, textContainer: textContainer)
        
        super.init()
        
        layoutManager.delegate = self
    }
    
}

extension MetaText {

    public struct SyncConfiguration {
        let attributedString: NSAttributedString
        let entities: [Meta.Entity]
        
        public init(attributedString: NSAttributedString, entities: [Meta.Entity]) {
            self.entities = entities
            self.attributedString = attributedString
        }
    }

    /// sync configure text and async configure meta
    /// - Parameters:
    ///   - text: input string
    ///   - entities: `[Meta]` wrappered in `Future`
    ///   - scheduler: meta configure scheduler. `RunLoop.main` or `DispatchQueue.main`
    /// - Returns: `AnyCancellable` from sink `entities`
    public func configure(syncConfiguration configuration: AnyPublisher<SyncConfiguration, Never>) -> AnyCancellable {
        return configuration
            .receive(on: ImmediateScheduler.shared)
            .sink { [weak self] configuration in
                guard let self = self else { return }
                self.entities = configuration.entities

                let attributedString = NSMutableAttributedString(attributedString: configuration.attributedString)
                var emojiAttachments: [MetaTextAttribute.EmojiAttachment] = []
                for entity in configuration.entities {
                    switch entity.meta {
                    case .emoji(_, let url, _):
                        let width = UIFontMetrics.default.scaledValue(for: 20)
                        let imageViewSize = CGSize(width: width, height: width)
                        let imageView = UIImageView(frame: CGRect(origin: .zero, size: imageViewSize))
                        imageView.backgroundColor = .red
                        self.textView.addSubview(imageView)
                        let attachment = MetaTextAttribute.EmojiAttachment(
                            size: imageViewSize,
                            view: imageView,
                            layoutInTextContainer: { imageView, frame in
                                imageView.frame = frame
                            }
                        )
                        emojiAttachments.append(attachment)
                        attributedString.addAttribute(
                            .metaEmojiText,
                            value: url,
                            range: entity.range
                        )
                        attributedString.addAttribute(
                            .metaEmojiAttachment,
                            value: attachment,
                            range: NSRange(location: entity.range.upperBound - 1, length: 1)
                        )
                    default:
                        // TODO:
                        continue
                    }
                }
                self.emojiAttachments = emojiAttachments
                self.textView.attributedText = attributedString
            }
    }
}

// MARK: - NSLayoutManagerDelegate
extension MetaText: NSLayoutManagerDelegate {

    struct EmojiMetaAttachmentInfo {
        let range: NSRange
        let attachment: MetaTextAttribute.EmojiAttachment
    }

    // ref: https://stackoverflow.com/a/57697139/3797903
    // ref: https://github.com/lingochamp/FuriganaTextView/blob/036225816aa8aab3d529b6be8b5475acf198b0c3/src/FuriganaWordKerner.swift
    public func layoutManager(
        _ layoutManager: NSLayoutManager,
        shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>,
        properties props: UnsafePointer<NSLayoutManager.GlyphProperty>,
        characterIndexes charIndexes: UnsafePointer<Int>,
        font aFont: UIFont,
        forGlyphRange glyphRange: NSRange
    ) -> Int {
        guard let textStorage = layoutManager.textStorage else {
            return 0
        }

        var newProperties: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>? = nil
        func allocNewProperties() {
            let sizeofProperties: Int = MemoryLayout<NSLayoutManager.GlyphProperty>.size * glyphRange.length
            newProperties = unsafeBitCast(malloc(sizeofProperties), to: UnsafeMutablePointer<NSLayoutManager.GlyphProperty>.self)
            memcpy(newProperties, props, sizeofProperties)
        }

        for i in 0..<glyphRange.length {
            let charIndex = charIndexes[i]

            let attributes = textStorage.attributes(at: charIndex, effectiveRange: nil)
            if attributes[.metaEmojiText] != nil {
                if newProperties == nil { allocNewProperties() }
                newProperties?[i].insert(.null)
            }

            if attributes[.metaEmojiAttachment] is MetaTextAttribute.EmojiAttachment {
                if newProperties == nil { allocNewProperties() }
                newProperties?[i] = .controlCharacter
            }
        }

        guard let properties = newProperties else {
            return 0
        }

        layoutManager.setGlyphs(glyphs,
            properties: properties,
            characterIndexes: charIndexes,
            font: aFont,
            forGlyphRange: glyphRange
        )
        free(newProperties)

        return glyphRange.length
    }

    public func layoutManager(
        _ layoutManager: NSLayoutManager,
        didCompleteLayoutFor textContainer: NSTextContainer?,
        atEnd layoutFinishedFlag: Bool
    ) {
        guard let textStorage = layoutManager.textStorage,
              let textContainer = textContainer else {
            return
        }
        
        let glyphRange = layoutManager.glyphRange(for: textContainer)

        let count = glyphRange.length
        var properties = [NSLayoutManager.GlyphProperty](repeating: [], count: count)
        var characterIndexes = [Int](repeating: 0, count: count)
        properties.withUnsafeMutableBufferPointer { props -> Void in
            characterIndexes.withUnsafeMutableBufferPointer { charIndexes -> Void  in
                layoutManager.getGlyphs(
                    in: glyphRange,
                    glyphs: nil,
                    properties: props.baseAddress,
                    characterIndexes: charIndexes.baseAddress,
                    bidiLevels: nil
                )
            }
        }

        for i in 0..<glyphRange.length where properties[i].contains(.controlCharacter) {
            let attributes = textStorage.attributes(at: characterIndexes[i], effectiveRange: nil)
            if let metaEmojiAttachment = attributes[.metaEmojiAttachment] as? MetaTextAttribute.EmojiAttachment {
                let glyphIndex = glyphRange.location + i
                let lineFragmentRectOrigin = layoutManager.lineFragmentRect(
                    forGlyphAt: glyphIndex,
                    effectiveRange: nil,
                    withoutAdditionalLayout: true
                ).origin
                let locationInLineFragment = layoutManager.location(forGlyphAt: glyphIndex)
                let locationInContainer = CGPoint(
                    x: lineFragmentRectOrigin.x + locationInLineFragment.x,
                    y: lineFragmentRectOrigin.y + 0.5 * locationInLineFragment.y
                )
                let frame = CGRect(origin: locationInContainer, size: metaEmojiAttachment.size)
                metaEmojiAttachment.layoutInTextContainer(metaEmojiAttachment.view, frame)
            }
        }
    }

    public func layoutManager(
        _ layoutManager: NSLayoutManager,
        shouldUse action: NSLayoutManager.ControlCharacterAction,
        forControlCharacterAt charIndex: Int
    ) -> NSLayoutManager.ControlCharacterAction {
        guard let textStorage = layoutManager.textStorage else {
            return action
        }

        let attributes = textStorage.attributes(at: charIndex, effectiveRange: nil)
        guard attributes[.metaEmojiAttachment] is MetaTextAttribute.EmojiAttachment else {
            return action
        }

        // `.whitespace` may not be set always by `NSTypesetter`.
        // This is only for control glyphs inserted by `layoutManager(_:shouldGenerateGlyphs:properties:characterIndexes:font:forGlyphRange:)`.
        return .whitespace
    }

    public func layoutManager(
        _ layoutManager: NSLayoutManager,
        boundingBoxForControlGlyphAt glyphIndex: Int,
        for textContainer: NSTextContainer,
        proposedLineFragment proposedRect: CGRect,
        glyphPosition: CGPoint,
        characterIndex charIndex: Int
    ) -> CGRect {
        guard let textStorage = layoutManager.textStorage else {
            return .zero
        }

        let attributes = textStorage.attributes(at: charIndex, effectiveRange: nil)
        guard let emojiAttachment = attributes[.metaEmojiAttachment] as? MetaTextAttribute.EmojiAttachment else {
            // Should't reach here.
            // See `layoutManager(_:shouldUse:forControlCharacterAt:)`.
            assertionFailure("Glyphs that have .suffixedAttachment shouldn't be a control glyphs")
            return .zero
        }

        return CGRect(origin: glyphPosition, size: emojiAttachment.size)
    }
}

extension NSAttributedString.Key {
    public static let metaEmojiText = NSAttributedString.Key(rawValue: "MetaEmojiTextKey")
    public static let metaEmojiAttachment = NSAttributedString.Key(rawValue: "MetaEmojiAttachmentKey")
}

public enum MetaTextAttribute {
    public class EmojiAttachment {
        public let size: CGSize
        public let view: UIView
        public let layoutInTextContainer: (UIView, CGRect) -> Void

        public init(size: CGSize, view: UIView, layoutInTextContainer: @escaping (UIView, CGRect) -> Void) {
            self.size = size
            self.view = view
            self.layoutInTextContainer = layoutInTextContainer
        }

        deinit {
            view.removeFromSuperview()
        }
    }
}
