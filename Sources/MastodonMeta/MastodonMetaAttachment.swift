//
//  MastodonMetaAttachment.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-26.
//

import os.log
import UIKit
import Combine
import UniformTypeIdentifiers
import SDWebImage
import Meta

public class MastodonMetaAttachmentView: UIView {
    
    var textAttachment: MastodonMetaAttachment? = nil
    
    init(textAttachment: MastodonMetaAttachment) {
        self.textAttachment = textAttachment
        super.init(frame: .zero)
        
        textAttachment.content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textAttachment.content)
        NSLayoutConstraint.activate([
            textAttachment.content.topAnchor.constraint(equalTo: topAnchor),
            textAttachment.content.leadingAnchor.constraint(equalTo: leadingAnchor),
            textAttachment.content.trailingAnchor.constraint(equalTo: trailingAnchor),
            textAttachment.content.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        textAttachment.imageView?.contentMode = .scaleAspectFit
        textAttachment.imageView?.sd_setImage(with: URL(string: textAttachment.url)) { [weak self] image, error, cacheType, url in
            guard let self = self else { return }
            guard let image = image else { return }
            guard let totalFrameCount = self.textAttachment?.imageView?.player?.totalFrameCount, totalFrameCount > 1
            else {
                // resize transformer not works for APNG
                // force resize for single frame animated image
                let scale: CGFloat = 3
                let size = CGSize(width: ceil(textAttachment.contentFrame.size.width * scale), height: ceil(textAttachment.contentFrame.size.height * scale))
                self.textAttachment?.imageView?.image = image.sd_resizedImage(with: size, scaleMode: .aspectFit)
                return
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var frame: CGRect {
        didSet {
            print(frame)
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return textAttachment?.contentFrame.size ?? .zero
    }
}

public class MastodonMetaAttachmentProvider: NSTextAttachmentViewProvider {
    public override func loadView() {
        guard let textAttachment = textAttachment as? MastodonMetaAttachment else { return }
        let attachmentView = MastodonMetaAttachmentView(textAttachment: textAttachment)
        view = attachmentView
    }
}

public class MastodonMetaAttachment: NSTextAttachment, MetaAttachment {
    
    public var disposeBag = Set<AnyCancellable>()
    
    static let placeholderImage: UIImage = {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(UIColor.clear.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }()

    let logger = Logger(subsystem: "MastodonMetaAttachment", category: "UI")

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
        image = MastodonMetaAttachment.placeholderImage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func image(
        for bounds: CGRect,
        attributes: [NSAttributedString.Key : Any] = [:],
        location: NSTextLocation,
        textContainer: NSTextContainer?
    ) -> UIImage? {
        contentFrame = bounds

        imageView?.contentMode = .scaleAspectFit
        imageView?.sd_setImage(with: URL(string: url)) { [weak self] image, error, cacheType, url in
            guard let self = self else { return }
            guard let image = image else { return }
            self.image = image

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
    
    public override func viewProvider(
        for parentView: UIView?,
        location: NSTextLocation,
        textContainer: NSTextContainer?
    ) -> NSTextAttachmentViewProvider? {
        let viewProvider = MastodonMetaAttachmentProvider(
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

