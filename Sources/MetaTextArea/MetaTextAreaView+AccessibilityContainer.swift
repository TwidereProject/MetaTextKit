//
//  MetaTextAreaView+AccessibilityContainer.swift
//  
//
//  Created by MainasuK on 2022-2-23.
//

import UIKit
import Meta

extension MetaTextAreaView {
    class AccessibilityContainer: UIAccessibilityElement {
        weak var container: MetaTextAreaView?
        let content: MetaContent
        
        init(
            accessibilityContainer container: MetaTextAreaView,
            content: MetaContent
        ) {
            self.container = container
            self.content = content
            super.init(accessibilityContainer: container)
        }
    }
}

extension MetaTextAreaView.AccessibilityContainer {
    override var accessibilityFrameInContainerSpace: CGRect {
        get {
            guard let container = self.container else {
                assertionFailure()
                return .zero
            }
            
            return container.bounds
        }
        set { }
    }
    
    override var accessibilityLabel: String? {
        get { content.string }
        set { }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get { .staticText }
        set { }
    }
}
