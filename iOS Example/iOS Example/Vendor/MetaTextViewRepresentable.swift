//
//  MetaTextViewRepresentable.swift
//
//
//  Created by MainasuK Cirno on 2021-7-16.
//

import os.log
import UIKit
import SwiftUI
import MetaTextKit

public struct MetaTextViewRepresentable: UIViewRepresentable {
    // let logger = Logger(subsystem: "MetaTextViewRepresentable", category: "View")
    let logger = Logger(.disabled)
    
    // input
    let metaContent: MetaContent
    
    // output
    let attributedString: NSAttributedString
    
    public init(
        metaContent: MetaContent
    ) {
        self.metaContent = metaContent
        self.attributedString = {
            let attributedString = NSMutableAttributedString(string: metaContent.string)
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.label,
            ]
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.systemBlue,
            ]
            let paragraphStyle: NSMutableParagraphStyle = {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 3
                style.paragraphSpacing = 8
                return style
            }()
            
            MetaText.setAttributes(
                for: attributedString,
                textAttributes: textAttributes,
                linkAttributes: linkAttributes,
                paragraphStyle: paragraphStyle,
                content: metaContent
            )
            
            return attributedString
        }()
        // end init
    }
    
    public func makeUIView(context: Context) -> MetaTextView {
        let metaText = MetaText()
        
        let textView = metaText.textView
        textView.backgroundColor = .clear                  // clear background
        textView.textContainer.lineFragmentPadding = 0     // remove leading inset
        textView.isScrollEnabled = false                   // enable dynamic height

        metaText.configure(content: metaContent)
        
        return textView
    }
    
    @available(iOS 16.0, *)
    public func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView textView: MetaTextView,
        context: Context
    ) -> CGSize? {
        let size = textView.sizeThatFits(CGSize(
            width: proposal.width ?? UIView.layoutFittingCompressedSize.width,
            height: UIView.layoutFittingCompressedSize.height
        ))
        return size
    }
    
    public func updateUIView(_ textView: MetaTextView, context: Context) {
        // do nothing
    }
    
}
