//
//  MediaMetaAttachmentView.swift
//  MetaTextKit
//
//  Created by MainasuK on 2024-12-17.
//

import os.log
import UIKit
import Combine
import UniformTypeIdentifiers
import SDWebImage

public class MediaMetaAttachmentView: UIView {

    var textAttachment: MediaMetaAttachment? = nil

    init(textAttachment: MediaMetaAttachment) {
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
            textAttachment.imageView?.backgroundColor = .systemYellow
        }
        #endif

        textAttachment.imageView?.contentMode = .scaleAspectFit
        textAttachment.imageView?.sd_setImage(with: URL(string: textAttachment.url)) { [weak self] image, error, cacheType, url in
            guard let self = self else { return }
            // do nothing
        }

        layer.cornerRadius = 12
        layer.masksToBounds = true
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
