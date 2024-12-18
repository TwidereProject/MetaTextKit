//
//  MediaMetaAttachment.swift
//  MetaTextKit
//
//  Created by MainasuK on 2024-12-17.
//

import os.log
import UIKit
import Combine
import UniformTypeIdentifiers
import SDWebImage

public class MediaMetaAttachment: NSTextAttachment, MetaAttachment {

    public var disposeBag = Set<AnyCancellable>()

    static let placeholderImage: UIImage = {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }()

    let logger = Logger(subsystem: "MediaMetaAttachment", category: "UI")

    public var string: String = ""
    public var url: String = ""
    public var size: CGSize = .zero
    public var content = UIView()
    public var contentFrame: CGRect = .zero
    public weak var viewProvider: NSTextAttachmentViewProvider?

    var imageView: SDAnimatedImageView? {
        return content as? SDAnimatedImageView
    }

    public init(string: String, url: String, size: CGSize, content: UIView) {
        self.string = string
        self.url = url
        self.content = content
        self.size = size
        super.init(data: nil, ofType: UTType.image.identifier)

        if #available(iOS 16, *) {
            allowsTextAttachmentView = true
        }
        image = MediaMetaAttachment.placeholderImage
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
            imageView?.backgroundColor = .yellow
        }
        #endif

        imageView?.contentMode = .scaleAspectFit
        imageView?.sd_setImage(with: URL(string: url)) { [weak self] image, error, cacheType, url in
            guard let self = self else { return }
            // do nothing
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
        let viewProvider = MediaMetaAttachmentViewProvider(
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

