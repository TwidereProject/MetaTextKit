//
//  MetaText.swift
//
//
//  Created by MainasuK Cirno on 2021-6-7.
//


import UIKit

open class MetaText: NSObject {
    
    public let textStorage: NSTextStorage
    public let textView: UITextView
    
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

// MARK: - NSLayoutManagerDelegate
extension MetaText: NSLayoutManagerDelegate {
    // ref: https://stackoverflow.com/a/57697139/3797903
    public func layoutManager(
        _ layoutManager: NSLayoutManager,
        shouldGenerateGlyphs glyphs: UnsafePointer<CGGlyph>,
        properties props: UnsafePointer<NSLayoutManager.GlyphProperty>,
        characterIndexes charIndexes: UnsafePointer<Int>,
        font aFont: UIFont,
        forGlyphRange glyphRange: NSRange
    ) -> Int {
        guard let textStorage = layoutManager.textStorage else {
            fatalError()
        }
        
        let firstCharIndex = charIndexes[0]
        let lastCharIndex = charIndexes[glyphRange.length - 1]
        let charRange = NSRange(location: firstCharIndex, length: lastCharIndex - firstCharIndex + 1)
        textStorage.enumerateAttributes(in: charRange, options: []) { attributes, range, _ in
            for attribute in attributes {
                
            }
        }
        
        var properties: [NSLayoutManager.GlyphProperty] = []
        for i in 0..<glyphRange.length {
            var property = props[i]
            property.insert(.null)
            properties.append(property)
        }
        properties.withUnsafeBufferPointer { bufferPointer in
            guard let propertiesPointer = bufferPointer.baseAddress else {
                fatalError()
            }
            layoutManager.setGlyphs(glyphs, properties: propertiesPointer, characterIndexes: charIndexes, font: aFont, forGlyphRange: glyphRange)
        }
        return glyphRange.length
    }
}
