//
//  MetaContent.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-25.
//

import UIKit

public protocol MetaContent {
    var string: String { get }
    var entities: [Meta.Entity] { get }

    func metaAttachment(for entity: Meta.Entity) -> MetaAttachment?
}

extension MetaContent {
    public func attributedString(
        accentColor: UIColor
    ) -> AttributedString {
        let nsAttributedString = NSMutableAttributedString(string: string)
        
        // meta
        let stringRange = NSRange(location: 0, length: nsAttributedString.length)
        for entity in entities {
            switch entity.meta {
            case .style(_, let styles, _):
                // add temp font attribute
                let range = NSIntersectionRange(stringRange, entity.range)
                let traits: UIFontDescriptor.SymbolicTraits = {
                    var traits: UIFontDescriptor.SymbolicTraits = []
                    if styles.contains(.bold) {
                        traits.insert(.traitBold)
                    }
                    if styles.contains(.italic) {
                        traits.insert(.traitItalic)
                    }
                    return traits
                }()
                let font: UIFont = {
                    let font = UIFont.systemFont(ofSize: 0, weight: .regular)
                    let fontDescriptor = font.fontDescriptor
                    guard let newFontDescriptor = fontDescriptor.withSymbolicTraits(traits) else {
                        return font
                    }
                    return UIFont(descriptor: newFontDescriptor, size: 0)
                }()
                nsAttributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
            default:
                let range = NSIntersectionRange(stringRange, entity.range)
                nsAttributedString.addAttribute(.link, value: entity.encodedPrimaryText, range: range)
                nsAttributedString.addAttribute(.foregroundColor, value: accentColor, range: range)
            }
        }
        
        var attributedString = AttributedString(nsAttributedString)

        // filter out temp font attribute run
        // and update the text style
        for run in attributedString.runs {
            guard let font = run.attributes.uiKit.font else { continue }
            let fontDescriptor = font.fontDescriptor
            let inlinePresentationIntent: InlinePresentationIntent = {
                var inlinePresentationIntent: InlinePresentationIntent = []
                if fontDescriptor.symbolicTraits.contains(.traitBold) {
                    inlinePresentationIntent.insert(.stronglyEmphasized)
                }
                if fontDescriptor.symbolicTraits.contains(.traitItalic) {
                    inlinePresentationIntent.insert(.emphasized)
                }
                return inlinePresentationIntent
            }()
            attributedString[run.range].inlinePresentationIntent = inlinePresentationIntent
            attributedString[run.range].font = nil
            // print(run)
        }
        
        return attributedString
    }
}
