//
//  AnimatedImageMetaAttachmentView.swift
//  MetaTextKit
//
//  Created by MainasuK on 2024-11-28.
//

import os.log
import UIKit
import Combine
import UniformTypeIdentifiers
import SDWebImage

public class AnimatedImageMetaAttachmentView: UIView {

    var textAttachment: AnimatedImageMetaAttachment? = nil

    init(textAttachment: AnimatedImageMetaAttachment) {
        self.textAttachment = textAttachment
        super.init(frame: .zero)

        textAttachment.content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textAttachment.content)
        NSLayoutConstraint.activate([
            textAttachment.content.topAnchor.constraint(equalTo: topAnchor),
            textAttachment.content.leadingAnchor.constraint(equalTo: leadingAnchor),
            textAttachment.content.trailingAnchor.constraint(equalTo: trailingAnchor),
            textAttachment.content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 5), // tweak the image position
        ])

        #if DEBUG
        if Meta.isDebugMode {
            textAttachment.imageView?.backgroundColor = .systemBlue
        }
        #endif

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
            // print(frame)
        }
    }

    public override var intrinsicContentSize: CGSize {
        return textAttachment?.contentFrame.size ?? .zero
    }
}
