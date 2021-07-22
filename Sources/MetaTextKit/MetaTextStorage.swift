//
//  MetaTextStorage.swift
//  
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit
import Meta

public protocol MetaTextStorageDelegate: AnyObject {
    func processEditing(_ textStorage: MetaTextStorage) -> MetaContent?
}

final public class MetaTextStorage: NSTextStorage {
    
    var storage = NSTextStorage()
    
    weak var processDelegate: MetaTextStorageDelegate?
    
    // MARK: - NSAttributedString primitives
    
    public override var string: String {
        storage.string
    }
    
    public override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        storage.attributes(at: location, effectiveRange: range)
    }
    
    // MARK: - NSMutableAttributedString primitives
    
    public override func replaceCharacters(in range: NSRange, with str: String) {
        storage.replaceCharacters(in: range, with: str)
        let delta: Int = {
            let string = str as NSString
            return string.length - range.length
        }()
        edited(.editedCharacters, range: range, changeInLength: delta)
    }
    
    public override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
    
}

extension MetaTextStorage {
    public override func processEditing() {
        _ = processDelegate?.processEditing(self)
        super.processEditing()
    }
}
