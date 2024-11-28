//
//  AnimatedImageMetaAttachment.swift
//
//
//  Created by Cirno MainasuK on 2021-6-26.
//

import os.log
import UIKit
import Combine
import UniformTypeIdentifiers
import SDWebImage

public class AnimatedImageMetaAttachment: NSTextAttachment, MetaAttachment {

    public var disposeBag = Set<AnyCancellable>()
    
    static let placeholderImage: UIImage = {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }()

    let logger = Logger(subsystem: "AnimatedImageMetaAttachment", category: "UI")

    public var string: String = ""
    public var url: String = ""
    public var content = UIView()
    public var contentFrame: CGRect = .zero
    public weak var viewProvider: NSTextAttachmentViewProvider?

    var imageView: SDAnimatedImageView? {
        return content as? SDAnimatedImageView
    }

    public init(string: String, url: String, content: UIView) {
        self.string = string
        self.url = url
        self.content = content
        super.init(data: nil, ofType: UTType.image.identifier)

        if #available(iOS 16, *) {
            allowsTextAttachmentView = true
        }
        image = AnimatedImageMetaAttachment.placeholderImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Custom init (MetaLabel & MetaArea)
    // OR
    // System selection or tap (TextView), seealso: AnimatedImageMetaAttachmentView
    // the layout will not change but the image will update
    public override func image(
        for bounds: CGRect,
        attributes: [NSAttributedString.Key : Any] = [:],
        location: NSTextLocation,
        textContainer: NSTextContainer?
    ) -> UIImage? {
        contentFrame = bounds

        #if DEBUG
        if Meta.isDebugMode {
            imageView?.backgroundColor = .red
        }
        #endif

        imageView?.contentMode = .scaleAspectFit
        imageView?.sd_setImage(with: URL(string: url)) { [weak self] image, error, cacheType, url in
            guard let self = self else { return }
            guard let image = image else { return }
            guard let totalFrameCount = self.imageView?.player?.totalFrameCount, totalFrameCount > 1
            else {
                // resize transformer not works for APNG
                // force resize for single frame animated image
                let scale: CGFloat = 3
                let size = CGSize(width: ceil(bounds.size.width * scale), height: ceil(bounds.size.height * scale))
                self.imageView?.image = image.sd_resizedImage(with: size, scaleMode: .aspectFit)
                return
            }
        }
        let image = super.image(for: bounds, attributes: attributes, location: location, textContainer: textContainer)
        return image
    }

    // TextKit 2 System (UITextView)
    public override func viewProvider(
        for parentView: UIView?,
        location: NSTextLocation,
        textContainer: NSTextContainer?
    ) -> NSTextAttachmentViewProvider? {
        let viewProvider = AnimatedImageMetaAttachmentViewProvider(
            textAttachment: self,
            parentView: parentView,
            textLayoutManager: textContainer?.textLayoutManager,
            location: location
        )
        viewProvider.tracksTextAttachmentViewBounds = true
        self.viewProvider = viewProvider
        return viewProvider
    }

}

