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
import Nuke
import Meta

public class MastodonMetaAttachment: NSTextAttachment, MetaAttachment {

    static let workingQueue = DispatchQueue(label: "MastodonMeta.MastodonMetaAttachment.workingQueue")
    static let placeholderImage: UIImage = {
        let size = CGSize(width: 1, height: 1)
        return UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(UIColor.systemFill.cgColor)
            context.fill(CGRect(origin: .zero, size: size))
        }
    }()
    static let pipeline = ImagePipeline { configuration in
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        configuration.dataLoadingQueue = operationQueue
        configuration.dataCachingQueue = operationQueue
        configuration.imageDecodingQueue = operationQueue
        configuration.imageEncodingQueue = operationQueue
        configuration.imageDecompressingQueue = operationQueue
    }

    let logger = Logger(subsystem: "MetaTextView", category: "MetaTextAttachment")

    public weak var delegate: MetaAttachmentDelegate?

    var disposeBag = Set<AnyCancellable>()

    public let string: String
    public let url: String

    public init(string: String, url: String) {
        self.string = string
        self.url = url
        super.init(data: nil, ofType: UTType.image.identifier)

        image = MastodonMetaAttachment.placeholderImage
    }

    public override func image(forBounds imageBounds: CGRect, textContainer: NSTextContainer?, characterIndex charIndex: Int) -> UIImage? {
        if disposeBag.isEmpty {
            // loading when needs
            MastodonMetaAttachment.pipeline.imagePublisher(with: url)
                .subscribe(on: MastodonMetaAttachment.workingQueue)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    switch completion {
                    case .failure:
                        // make re-entry possible when failure
                        self.disposeBag.removeAll()
                    case .finished:
                        break
                    }
                } receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    self.image = response.image
                    self.delegate?.metaAttachment(self, imageUpdated: response.image)
                }
                .store(in: &disposeBag)
        }

        return super.image(forBounds: imageBounds, textContainer: textContainer, characterIndex: charIndex)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        disposeBag.removeAll()
        // logger.debug("deinit")
    }

}

