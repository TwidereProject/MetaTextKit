//
//  MastodonStatusViewController.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import os.log
import UIKit
import Meta
import MastodonMeta
import MetaTextKit
import MetaTextArea
import MetaLabel

class MastodonStatusViewController: UIViewController {

    let singleLineMetaText: MetaText = {
        let metaText = MetaText()
        metaText.textView.textContainer.maximumNumberOfLines = 1
        metaText.textView.isEditable = false
        metaText.textView.isScrollEnabled = false
        return metaText
    }()
    let metaLabel = MetaLabel()
    let label = UILabel()
    
    let metaText = MetaText()
    let textArea = MetaTextAreaView()
    let textView = UITextView()

    var attachments: [NSTextAttachment] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Mastodon Status"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: nil,
            image: UIImage(systemName: "ellipsis.circle"),
            primaryAction: nil,
            menu: UIMenu(
                title: "", image: nil, identifier: nil, options: [], children: [
                    UIAction(title: "End Editing", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.view.endEditing(true)
                    }),
                    UIAction(title: "Reload Content", image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.setupTextEditorContent()
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

        let lineContainer = UIStackView()
        lineContainer.axis = .horizontal
        
        lineContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineContainer)
        NSLayoutConstraint.activate([
            lineContainer.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            lineContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        lineContainer.addArrangedSubview(singleLineMetaText.textView)
        singleLineMetaText.textView.backgroundColor = .systemGray
        
        let label1 = UILabel()
        label1.text = "Some Extra Texts"
        lineContainer.addArrangedSubview(label1)
        label1.setContentCompressionResistancePriority(.required - 1, for: .horizontal)
        
        let lineContainer2 = UIStackView()

        lineContainer2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineContainer2)
        NSLayoutConstraint.activate([
            lineContainer2.topAnchor.constraint(equalTo: lineContainer.bottomAnchor),
            lineContainer2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineContainer2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        lineContainer2.addArrangedSubview(metaLabel)
        metaLabel.backgroundColor = .systemGray3
        metaLabel.setContentHuggingPriority(.required - 1, for: .horizontal)
        
        let label2 = UILabel()
        label2.text = "@username"
        lineContainer2.addArrangedSubview(label2)
        label2.setContentCompressionResistancePriority(.required - 1, for: .horizontal)
        
        let lineContainer3 = UIStackView()
        lineContainer3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineContainer3)
        NSLayoutConstraint.activate([
            lineContainer3.topAnchor.constraint(equalTo: lineContainer2.bottomAnchor),
            lineContainer3.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lineContainer3.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        lineContainer3.addArrangedSubview(label)

        metaText.textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metaText.textView)
        NSLayoutConstraint.activate([
            metaText.textView.topAnchor.constraint(equalTo: lineContainer3.bottomAnchor),
            metaText.textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metaText.textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        metaText.textView.backgroundColor = .systemGray2
        
        textArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textArea)
        NSLayoutConstraint.activate([
            textArea.topAnchor.constraint(equalTo: metaText.textView.bottomAnchor),
            textArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textArea.heightAnchor.constraint(equalTo: metaText.textView.heightAnchor),
        ])
        textArea.backgroundColor = .systemGray
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textArea.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.heightAnchor.constraint(equalTo: metaText.textView.heightAnchor),
        ])
        textView.backgroundColor = .systemGray2

        metaText.delegate = self

//        setupsingleLineMetaTextContent()
//        setupMetaLabelContent()
        setupLabelContent()
        
//        setupTextEditorContent()
//        setupTextAreaContext()
//        setupTextViewContext()
    }

}

extension MastodonStatusViewController {

    func setupsingleLineMetaTextContent() {
        let content = (0..<100)
            .compactMap { _ in ":" + emojis.keys.randomElement()! + ":" }
            .joined(separator: " ")
            
        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: "MetaText Single Line (TextKit)" + content, emojis: emojis)
            )
            singleLineMetaText.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }
    
    func setupMetaLabelContent() {
        let content = (0..<4)
            .compactMap { _ in ":" + emojis.keys.randomElement()! + ":" }
            .joined(separator: " ")

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: "MetaLabel (TextKit 2)" + content, emojis: emojis)
            )
            metaLabel.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }
    
    func setupLabelContent() {
        let content = (0..<4)
            .compactMap { _ in ":" + emojis.keys.randomElement()! + ":" }
            .joined(separator: " ")

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: "UILabel (TextKit 2)" + content, emojis: emojis)
            )
            let attributedString = NSMutableAttributedString(string: metaContent.string)
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 17, weight: .regular)),
                .foregroundColor: UIColor.label,
            ]
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold)),
                .foregroundColor: UIColor.link,
            ]
            let paragraphStyle: NSMutableParagraphStyle = {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                style.paragraphSpacing = 8
                return style
            }()
            
            MetaText.setAttributes(
                for: attributedString,
                   textAttributes: textAttributes,
                   linkAttributes: linkAttributes,
                   paragraphStyle: paragraphStyle,
                   content: metaContent
            )
            label.attributedText = attributedString
        } catch {
            assertionFailure()
        }
    }

    func setupTextEditorContent() {
        let statusContent = """
        <p>MetaText Editor (TextKit):<br><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:<a href="https://mstdn.jp/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a> <a href="https://example.com/welcome/2021/02/01" rel="nofollow noopener noreferrer" target="_blank">https://example.com/welcome/<span class="invisible">2021/02/01</span></a></p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p>
        """

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: statusContent, emojis: emojis)
            )
            metaText.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }
    
    func setupTextAreaContext() {
        let statusContent = """
        <p>MetaTextArea ReadOnly (TextKit 2):<br><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:<a href="https://mstdn.jp/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a> <a href="https://example.com/welcome/2021/02/01" rel="nofollow noopener noreferrer" target="_blank">https://example.com/welcome/<span class="invisible">2021/02/01</span></a></p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p>
        """

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: statusContent, emojis: emojis)
            )
            textArea.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }
    
    func setupTextViewContext() {
        let statusContent = """
        <p>UITextView (iOS 16 TextKit 2):<br><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:<a href="https://mstdn.jp/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a> <a href="https://example.com/welcome/2021/02/01" rel="nofollow noopener noreferrer" target="_blank">https://example.com/welcome/<span class="invisible">2021/02/01</span></a></p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p>
        """

        do {
            let content = try MastodonMetaContent.convert(
                document: MastodonContent(content: statusContent, emojis: emojis)
            )
            let attributedString = NSMutableAttributedString(string: content.string)
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 17, weight: .regular)),
                .foregroundColor: UIColor.label,
            ]
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold)),
                .foregroundColor: UIColor.link,
            ]
            let paragraphStyle: NSMutableParagraphStyle = {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                style.paragraphSpacing = 8
                return style
            }()
            
            MetaText.setAttributes(
                for: attributedString,
                   textAttributes: textAttributes,
                   linkAttributes: linkAttributes,
                   paragraphStyle: paragraphStyle,
                   content: content
            )
            textView.textStorage.setAttributedString(attributedString)
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
            "awesome": "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png",
            "ablobattention": "https://media.mstdn.jp/custom_emojis/images/000/123/539/original/f3b1abf131a34b6c.png",
            "ablobcaramelldansen": "https://media.mstdn.jp/custom_emojis/images/000/120/885/original/75cb4f59948b69ce.png",
            "ablobattentionreverse": "https://media.mstdn.jp/custom_emojis/images/000/120/907/original/d0320f5180028c28.png",
        ]
    }

}
