//
//  MetaTextAreaView+AccessibilityElement.swift
//  
//
//  Created by MainasuK on 2022-2-22.
//

import UIKit
import Meta

extension MetaTextAreaView {
    class AccessibilityElement: UIAccessibilityElement {
        weak var container: MetaTextAreaView?
        let entity: Meta.Entity

        init(
            accessibilityContainer container: MetaTextAreaView,
            entity: Meta.Entity
        ) {
            self.container = container
            self.entity = entity
            super.init(accessibilityContainer: container)
        }
    }
}

extension MetaTextAreaView.AccessibilityElement {
    override var accessibilityFrameInContainerSpace: CGRect {
        get {
            var frame: CGRect = .zero
            guard let container = self.container else {
                assertionFailure()
                return frame
            }
            if let documentRange = NSTextRange(
                location: container.textContentStorage.documentRange.location,
                end: container.textContentStorage.documentRange.endLocation
            ) {
                container.textLayoutManager.ensureLayout(for: documentRange)
            } else {
                assertionFailure()
            }
            
            let entity = self.entity
            let _entityTextLocation = container.textContentStorage.location(
                container.textContentStorage.documentRange.location,
                offsetBy: entity.range.location
            )
            
            guard let entityTextLocation = _entityTextLocation,
                  let layoutFragment = container.textLayoutManager.textLayoutFragment(for: entityTextLocation)
            else {
                assertionFailure()
                return frame
            }
            
            let layoutFragmentRangeInElement = layoutFragment.rangeInElement
            // The location for layoutFragment range start in element (storage)
            // Also, that's the base location for the textLineFragment's characterRange
            let layoutFragmentTextLocation = container.textContentStorage.offset(
                from: container.textContentStorage.documentRange.location,
                to: layoutFragmentRangeInElement.location
            )
            
            var currentLineFragmentTextLocation = layoutFragmentTextLocation
            for textLineFragment in layoutFragment.textLineFragments {
                defer { currentLineFragmentTextLocation += textLineFragment.characterRange.length }

                let textLineFragmentRangeInElement = NSRange(
                    location: currentLineFragmentTextLocation,
                    length: textLineFragment.characterRange.length
                )
                // print("textLineFragment: \(textLineFragment), range: \(textLineFragmentRangeInElement), entityRange: \(entity.range)")
                
                guard let intersectionRangeInElement = textLineFragmentRangeInElement.intersection(entity.range) else {
                    continue
                }
                // intersectionTextLocationInLine is the intersection range start location in characterRange from textLineFragment
                // that location is valid location to call `locationForCharacter` method
                let intersectionTextLocationInLine = intersectionRangeInElement.location - layoutFragmentTextLocation
                let intersectionEndTextLocationInLine = intersectionTextLocationInLine + intersectionRangeInElement.length
                let startPoint = textLineFragment.locationForCharacter(at: intersectionTextLocationInLine)
                let endPoint = textLineFragment.locationForCharacter(at: intersectionEndTextLocationInLine)
                
                let rect = CGRect(
                    x: startPoint.x,
                    y: layoutFragment.layoutFragmentFrame.minY + textLineFragment.typographicBounds.minY,
                    width: endPoint.x - startPoint.x,
                    height: textLineFragment.typographicBounds.height
                )
                
                // union valid rect in the multiple textLineFragments for which entity exists in the multiple lines
                frame = frame != .zero ? frame.union(rect) : rect
            }

            return frame
        }
        set { }
    }
    
    override var accessibilityLabel: String? {
        get { entity.primaryText }
        set { }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            switch entity.meta {
            case .url, .hashtag, .mention, .email:
                return .link
            case .emoji:
                return .staticText
            }
        }
        set { }
    }
}
