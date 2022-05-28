//
//  TwitterStatusViewController.swift
//  
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import os.log
import UIKit
import Meta
import TwitterMeta
import MetaTextKit
import twitter_text

class TwitterStatusViewController: UIViewController {

    let metaText = MetaText()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Twitter Status"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "ellipsis.circle"),
            primaryAction: nil,
            menu: UIMenu(
                title: "", image: nil, identifier: nil, options: [], children: [
                    UIAction(title: "Reload Content", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.setupContent()
                    }),
                ]
            )
        )

        metaText.textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metaText.textView)
        NSLayoutConstraint.activate([
            metaText.textView.topAnchor.constraint(equalTo: view.topAnchor),
            metaText.textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metaText.textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metaText.textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        metaText.delegate = self

        setupContent()
    }

}

extension TwitterStatusViewController {

    func setupContent() {
        let statusContent = """
        Tweet: \n@username: Hello 你好 こんにちは 😂😂😂 #hashtag https://twitter.com/ABCDEFG
        """
        let content = TwitterContent(content: statusContent)
        let metaContent = TwitterMetaContent.convert(
            content: content,
            urlMaximumLength: 0,
            twitterTextProvider: OfficialTwitterTextProvider()
        )
        metaText.configure(content: metaContent)
    }

}

// MARK: - MetaTextDelegate
extension TwitterStatusViewController: MetaTextDelegate {
    func metaText(_ metaText: MetaText, processEditing textStorage: MetaTextStorage) -> MetaContent? {
        guard metaText === self.metaText else { return nil }
        os_log(.info, "%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)

        let string = metaText.textStorage.string
        let content = TwitterContent(content: string)
        let metaContent = TwitterMetaContent.convert(
            content: content,
            urlMaximumLength: 0,
            twitterTextProvider: OfficialTwitterTextProvider()
        )

        return metaContent
    }
}

public class OfficialTwitterTextProvider: TwitterTextProvider {
    public func entities(in text: String) -> [TwitterTextProviderEntity] {
        return TwitterText.entities(inText: text).compactMap { entity in
            switch entity.type {
            case .URL:              return .url(range: entity.range)
            case .screenName:       return .screenName(range: entity.range)
            case .hashtag:          return .hashtag(range: entity.range)
            case .listName:         return .listName(range: entity.range)
            case .symbol:           return .symbol(range: entity.range)
            case .tweetChar:        return .tweetChar(range: entity.range)
            case .tweetEmojiChar:   return .tweetEmojiChar(range: entity.range)
            @unknown default:
                assertionFailure()
                return nil
            }
        }
    }
}
