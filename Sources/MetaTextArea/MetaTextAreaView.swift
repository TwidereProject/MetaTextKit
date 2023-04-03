//
//  MetaTextAreaView.swift
//  MetaTextAreaView
//
//  Created by Cirno MainasuK on 2021-7-30.
//

import os.log
import UIKit
import Combine
import Meta

public protocol MetaTextAreaViewDelegate: AnyObject {
    func metaTextAreaView(_ metaTextAreaView: MetaTextAreaView, didSelectMeta meta: Meta)
}

public class MetaTextAreaView: UIView {
    
    var disposeBag = Set<AnyCancellable>()
    
    // let logger = Logger(subsystem: "MetaTextAreaView", category: "Layout")
    let logger = Logger(OSLog.disabled)
         
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    public let textContentStorage = NSTextContentStorage()
    public let textLayoutManager = NSTextLayoutManager()
    public let textContainer = NSTextContainer()
    
    public var paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        style.paragraphSpacing = 8
        return style
    }()
    
    static var fontSize: CGFloat = 17
    
    public var textAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: MetaTextAreaView.fontSize, weight: .regular)),
        .foregroundColor: UIColor.label,
    ]
    
    public var linkAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: MetaTextAreaView.fontSize, weight: .semibold)),
        .foregroundColor: UIColor.link,
    ]
    
    private let attachmentView = UIView()
    private let contentLayer = MetaTextAreaLayer()
    let fragmentLayerMap = NSMapTable<NSTextLayoutFragment, CALayer>.weakToWeakObjects()
    
    #if DEBUG
    public static var showLayerFrames: Bool = false
    #endif
    
    public var preferredMaxLayoutWidth: CGFloat?
    public weak var delegate: MetaTextAreaViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func _init() {
        attachmentView.frame = bounds
        addSubview(attachmentView)
        layer.addSublayer(contentLayer)
        
        textContentStorage.addTextLayoutManager(textLayoutManager)
        textLayoutManager.textContainer = textContainer
    
        textContainer.lineFragmentPadding = 0
        
        // DEBUG
        // showLayerFrames = true
        
        textLayoutManager.delegate = self                               ///< NSTextLayoutManagerDelegate
        textLayoutManager.textViewportLayoutController.delegate = self  ///< NSTextViewportLayoutControllerDelegate
        
        addGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(MetaTextAreaView.tapGestureRecognizerHandler(_:)))
        tapGestureRecognizer.delaysTouchesBegan = false
        
        accessibilityContainerType = .semanticGroup
        
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                print("container: \(self.textContainer.size.debugDescription), frame: \(self.frame)")
                
                if self.textContainer.size.height >= 10000000 {
                    self.invalidateIntrinsicContentSize()
                    _ = self.intrinsicContentSize
                } else {
                    _ = self.intrinsicContentSize
                }
                
                if self.frame != .zero {
                    self.textLayoutManager.textViewportLayoutController.layoutViewport()
                }
            }
            .store(in: &disposeBag)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        invalidateIntrinsicContentSize()
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): bounds \(self.bounds.debugDescription)")
    }

    
    public override var intrinsicContentSize: CGSize {
        let width: CGFloat = {
            if bounds.width == .zero {
                return preferredMaxLayoutWidth ?? UIScreen.main.bounds.width
            } else {
                return bounds.width
            }
        }()
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let _intrinsicContentSize = sizeThatFits(size)
        if frame == .zero {
            self.frame.size = _intrinsicContentSize
            self.textContainer.size = _intrinsicContentSize
            self.textLayoutManager.textViewportLayoutController.layoutViewport()
        }
        return _intrinsicContentSize
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        // update textContainer width
        if textContainer.maximumNumberOfLines == 1 {
            textContainer.size.width = UIScreen.main.bounds.width
            textContainer.size.height = .zero
        } else {
            textContainer.size.width = size.width
            textContainer.size.height = .zero
        }
        
        // needs always draw to fit tableView/collectionView cell reusing
        // also, make precise height calculate possible
        textLayoutManager.textViewportLayoutController.layoutViewport()
        
        // calculate height
        var height: CGFloat = 0
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.endLocation,
            options: [.reverse, .ensuresLayout]
        ) { layoutFragment in
            height = layoutFragment.layoutFragmentFrame.maxY
            return false // stop
        }
        
        var newSize = size
        newSize.height = ceil(height)
        
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): \(newSize.debugDescription)")
        
        return newSize
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // trigger sizeThatFits()
        self.invalidateIntrinsicContentSize()
    }
    
    deinit {
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public)")
    }
    
}

extension MetaTextAreaView {
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return meta(at: point) != nil
    }
    
    func meta(at point: CGPoint) -> Meta? {
        guard let fragment = textLayoutManager.textLayoutFragment(for: point) else { return nil }
        
        let pointInFragmentFrame = CGPoint(
            x: point.x - fragment.layoutFragmentFrame.origin.x,
            y: point.y - fragment.layoutFragmentFrame.origin.y
        )
        let lines = fragment.textLineFragments
        guard let lineIndex = lines.firstIndex(where: { $0.typographicBounds.contains(pointInFragmentFrame) }) else { return nil }
        guard lineIndex < lines.count else { return nil }
        let line = lines[lineIndex]
        
        let characterIndex = line.characterIndex(for: point)
        guard characterIndex >= 0, characterIndex < line.attributedString.length else { return nil }
        
        guard let meta = line.attributedString.attribute(.meta, at: characterIndex, effectiveRange: nil) as? Meta else {
            return nil
        }
        return meta
    }
    
}

extension MetaTextAreaView {
    @objc private func tapGestureRecognizerHandler(_ sender: UITapGestureRecognizer) {
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public)")
        switch sender.state {
        case .ended:
            let point = sender.location(in: self)
            guard let meta = meta(at: point) else { return }
            delegate?.metaTextAreaView(self, didSelectMeta: meta)
        default:
            break
        }
    }
}

extension MetaTextAreaView {
    public func setAttributedString(_ attributedString: NSAttributedString) {
        textContentStorage.textStorage?.setAttributedString(attributedString)
        invalidateIntrinsicContentSize()
    }
}

extension MetaTextAreaView {
    private func resetContent() {
        attachmentView.subviews.forEach { view in view.removeFromSuperview() }
        contentLayer.sublayers?.forEach { layer in layer.removeFromSuperlayer() }
        contentLayer.sublayers = nil
        fragmentLayerMap.removeAllObjects()
    }
}

// MARK: - NSTextViewportLayoutControllerDelegate
extension MetaTextAreaView: NSTextViewportLayoutControllerDelegate {
    
    public func viewportBounds(for textViewportLayoutController: NSTextViewportLayoutController) -> CGRect {
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): return viewportBounds: \(self.bounds.debugDescription)")
        return bounds
//        return CGRect(
//            origin: .zero,
//            size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
//        )
    }
    
    public func textViewportLayoutControllerWillLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public)")
        
        resetContent()
    }
    
    private func findOrCreateLayer(_ textLayoutFragment: NSTextLayoutFragment) -> (MetaTextLayoutFragmentLayer, Bool) {
        if let layer = fragmentLayerMap.object(forKey: textLayoutFragment) as? MetaTextLayoutFragmentLayer {
            return (layer, false)
        } else {
            let layer = MetaTextLayoutFragmentLayer(textLayoutFragment: textLayoutFragment)
            layer.contentView = attachmentView
            fragmentLayerMap.setObject(layer, forKey: textLayoutFragment)
            return (layer, true)
        }
    }
    
    public func textViewportLayoutController(
        _ textViewportLayoutController: NSTextViewportLayoutController,
        configureRenderingSurfaceFor textLayoutFragment: NSTextLayoutFragment
    ) {
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): textLayoutFragment \(textLayoutFragment)")
        
        let (textLayoutFragmentLayer, isCreate) = findOrCreateLayer(textLayoutFragment)
        contentLayer.addSublayer(textLayoutFragmentLayer)

        if !isCreate {
        }
        textLayoutFragmentLayer.updateGeometry()
        // always redraw when layout to meet preferred content size and Dark/Light Mode changing
        textLayoutFragmentLayer.setNeedsDisplay()
        
        #if DEBUG
        if textLayoutFragmentLayer.showLayerFrames != MetaTextAreaView.showLayerFrames {
            textLayoutFragmentLayer.showLayerFrames = MetaTextAreaView.showLayerFrames
            textLayoutFragmentLayer.setNeedsDisplay()
        }
        #endif
        
        textLayoutFragmentLayer.displayIfNeeded()
    }
    
    public func textViewportLayoutControllerDidLayout(_ textViewportLayoutController: NSTextViewportLayoutController) {
        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public)")
    }
    
}

// MARK: - NSTextLayoutManagerDelegate
extension MetaTextAreaView: NSTextLayoutManagerDelegate {
//    public func textLayoutManager(_ textLayoutManager: NSTextLayoutManager, textLayoutFragmentFor location: NSTextLocation, in textElement: NSTextElement) -> NSTextLayoutFragment {
//        logger.log(level: .debug, "\((#file as NSString).lastPathComponent, privacy: .public)[\(#line, privacy: .public)], \(#function, privacy: .public): location: \(location.debugDescription ?? ""), element: \(textElement.debugDescription)")
//        
//        let documentRangeLocation = textLayoutManager.documentRange.location
//        if let elementRangeLocation = textElement.elementRange?.location,
//           elementRangeLocation.compare(documentRangeLocation) == .orderedSame {
//            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//        } else {
//            return MetaParagraphTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
//        }
//    }
}
