//
//  MetaTextAreaView+MetaContent.swift
//  MetaTextAreaView+MetaContent
//
//  Created by Cirno MainasuK on 2021-9-3.
//

import UIKit
import Meta
import MetaTextKit

extension MetaTextAreaView {
    
    public func configure(content: MetaContent) {
        let attributedString = NSMutableAttributedString(string: content.string)

        let iOS16: Bool
        if #available(iOS 16, *) {
            iOS16 = true
        } else {
            iOS16 = false
        }

        MetaText.setAttributes(
            for: attributedString,
               textAttributes: textAttributes,
               linkAttributes: linkAttributes,
               paragraphStyle: paragraphStyle,
            content: content,
            useTextKit2: iOS16
        )
        
        setAttributedString(attributedString)
        
        // a11y
        let elements = content.entities.compactMap { entity -> AccessibilityElement? in
            switch entity.meta {
            case .url, .hashtag, .cashtag, .mention, .email:
                return AccessibilityElement(accessibilityContainer: self, entity: entity)
            case .emoji:
                return nil
            }
        }
        
        let container = AccessibilityContainer(accessibilityContainer: self, content: content)
        
        accessibilityElements = [container] + elements
    }
    
    public func reset() {
        let attributedString = NSAttributedString(string: "")
        setAttributedString(attributedString)
        accessibilityElements = nil
    }
    
}
