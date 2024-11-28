//
//  TwitterStatusViewController.swift
//  
//
//  Created by MainasuK Cirno on 2021-7-13.
//

import os.log
import UIKit
import Meta
import MetaTextKit
import TwitterMeta
import twitter_text

class TwitterStatusViewController: UIViewController {

    let metaText: MetaText = {
        let metaText = MetaText()
        metaText.textView.isScrollEnabled = false
        return metaText
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Twitter Status"

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.frameLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.frameLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let lineContainer = UIStackView()
        lineContainer.axis = .vertical
        lineContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(lineContainer)
        NSLayoutConstraint.activate([
            lineContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            lineContainer.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            lineContainer.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            lineContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            lineContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        lineContainer.addArrangedSubview(metaText.textView)
        metaText.textView.backgroundColor = .systemGray
        setupMetaTextContent()
        metaText.delegate = self
    }

}

extension TwitterStatusViewController {

    func setupMetaTextContent() {
        let statusContent = """
        (MetaText, TextKit, Editor): \n@username: Hello 你好 こんにちは 😂😂😂 #hashtag https://twitter.com/ABCDEFG
        """
        let content = TwitterContent(
            content: statusContent,
            urlEntities: []
        )
        let metaContent = TwitterMetaContent.convert(
            text: content,
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
        let content = TwitterContent(
            content: string,
            urlEntities: []
        )
        let metaContent = TwitterMetaContent.convert(
            text: content,
            urlMaximumLength: 0,
            twitterTextProvider: OfficialTwitterTextProvider()
        )

        return metaContent
    }
}

public class OfficialTwitterTextProvider: TwitterTextProvider {
    
    public static let parser = TwitterTextParser.defaultParser()
    
    public func parse(text: String) -> ParseResult {
        let result = OfficialTwitterTextProvider.parser.parseTweet(text)

        return ParseResult(
            isValid: result.isValid,
            weightedLength: result.weightedLength,
            maxWeightedLength: OfficialTwitterTextProvider.parser.maxWeightedTweetLength(),
            entities: self.entities(in: text)
        )
    }
    
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
