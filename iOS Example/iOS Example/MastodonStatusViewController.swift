//
//  MastodonStatusViewController.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import os.log
import UIKit
import Meta
import MetaTextView
import MastodonMeta

class MastodonStatusViewController: UIViewController {

    let metaText = MetaText()

    var attachments: [NSTextAttachment] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Mastodon Status"
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
                    UIAction(title: "Load Emojis", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.setupEmojis(count: 100)
                    }),
                    UIAction(title: "Load Too Many Emojis", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.setupEmojis(count: 999)
                    }),
                    UIAction(title: "Add NSTextAttachment", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] _ in
                        guard let self = self else { return }
                        let textAttachment = NSTextAttachment(image: UIImage(systemName: "photo")!)
                        let attributedString = NSAttributedString(attachment: textAttachment)
                        self.metaText.textView.textStorage.append(attributedString)
                        self.attachments.append(textAttachment)
                    }),
                    UIAction(title: "Change Attachment Image", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] _ in
                        guard let self = self else { return }
                        for attachment in self.attachments {
                            attachment.image = UIImage(systemName: "signature")!
                        }
                        self.metaText.textView.setNeedsDisplay()
                    })
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

extension MastodonStatusViewController {

    func setupContent() {
        let statusContent = """
        <p>Mastodon:<br><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> Hello 你好 こんにちは 😂😂:awesome: <a href="https://mstdn.jp/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a> <a href="https://example.com/welcome/2021/02/01" rel="nofollow noopener noreferrer" target="_blank">https://example.com/welcome/<span class="invisible">2021/02/01</span></a></p>
        """
        let emojis: [String: String] = [
            "apple_inc": "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png",
            "awesome": "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png"
        ]

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: statusContent, emojis: emojis)
            )
            metaText.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }

    func setupEmojis(count: Int) {
        let statusContent = (0..<count)
            .map { _ in
                let shortcode = emojis.keys.randomElement()!
                return ":" + shortcode + ":"
            }
            .joined(separator: "")

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: statusContent, emojis: emojis)
            )
            metaText.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }

}

// MARK: - MetaTextDelegate
extension MastodonStatusViewController: MetaTextDelegate {
    func metaText(_ metaText: MetaText, processEditing textStorage: MetaTextStorage) -> MetaContent? {
        guard metaText === self.metaText else { return nil }
        os_log(.info, "%{public}s[%{public}ld], %{public}s", ((#file as NSString).lastPathComponent), #line, #function)

        let string = metaText.textStorage.string
        let content = MastodonContent(content: string, emojis: emojis)
        let metaContent = MastodonMetaContent.convert(text: content)

        // print("---input---")
        // print(string)
        // print("---entities---")
        // debugPrint(metaContent.entities)
        // print("---end---\n")

        return metaContent
    }
}

extension MastodonStatusViewController {
    var emojis: [String: String] {
        [
            "apple_inc": "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png",
            "awesome": "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png"
        ]
    }
}
