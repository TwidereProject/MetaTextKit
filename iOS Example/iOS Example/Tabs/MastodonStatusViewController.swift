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

    // TextKit 1
    let singleLineMetaText: MetaText = {
        let metaText = MetaText()
        metaText.textView.textContainer.maximumNumberOfLines = 2
        metaText.textView.isEditable = false
        metaText.textView.isScrollEnabled = false
        return metaText
    }()
    let singleLineMetaText2: MetaText = {
        let metaText = MetaText()
        metaText.textView.textContainer.maximumNumberOfLines = 2
        metaText.textView.isEditable = false
        metaText.textView.isScrollEnabled = false
        return metaText
    }()
    let multilineEditorMetaText: MetaText = {
        let metaText = MetaText()
        metaText.textView.isEditable = true
        metaText.textView.isScrollEnabled = false
        return metaText
    }()

    // TextKit 2
    let metaLabel = MetaLabel()
    let textArea = MetaTextAreaView()

    // UIKit
    let label = UILabel()
    let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        return textView
    }()

    var attachments: [NSTextAttachment] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Mastodon Status"

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

        // single line (MetaText, TextKit 1)
        lineContainer.addArrangedSubview(singleLineMetaText.textView)
        singleLineMetaText.textView.backgroundColor = .systemGray
        setupSingleLineMetaTextContent()

        // single line + normal UILabel
        let rowContainer = UIStackView()
        rowContainer.axis = .horizontal
        lineContainer.addArrangedSubview(rowContainer)
        rowContainer.addArrangedSubview(singleLineMetaText2.textView)
        singleLineMetaText2.textView.backgroundColor = .systemGray2
        setupSingleLineMetaText2Content()
        let label2 = UILabel()
        label2.text = "concat UILabel"
        rowContainer.addArrangedSubview(label2)
        label2.backgroundColor = .systemGray2.withAlphaComponent(0.5)
        label2.setContentCompressionResistancePriority(.required - 1, for: .horizontal)

        // multi-line (MetaText, TextKit 1)
        lineContainer.addArrangedSubview(multilineEditorMetaText.textView)
        multilineEditorMetaText.textView.backgroundColor = .systemGray3
        setupMultilineEditorMetaTextContent()
        multilineEditorMetaText.delegate = self

        // single line (MetaLabel, TextKit 2)
        lineContainer.addArrangedSubview(metaLabel)
        metaLabel.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        setupMetaLabelContent()

        // multi-line (MetaArea, TextKit 2)
        lineContainer.addArrangedSubview(textArea)
        textArea.backgroundColor = .systemOrange.withAlphaComponent(0.5)
        setupTextAreaContext()

        // single line (UIlabel, TextKit 2)
        lineContainer.addArrangedSubview(label)
        label.backgroundColor = .systemRed.withAlphaComponent(0.5)
        setupLabelContent()

        // multi-line (UITextView, TextKit 2)
        lineContainer.addArrangedSubview(textView)
        textView.backgroundColor = .systemPink.withAlphaComponent(0.5)
        setupTextViewContext()
    }

}

extension MastodonStatusViewController {

    func setupSingleLineMetaTextContent() {
        let content = (0..<100)
            .compactMap { _ in ":" + emojis.keys.randomElement()! + ":" }
            .joined(separator: " ")
            
        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: "(MetaText, TextKit, Selectable)\nEmoji only display on iOS 15" + content, emojis: emojis)
            )
            singleLineMetaText.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }

    func setupSingleLineMetaText2Content() {
        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: "(MetaText, TextKit, Selectable)", emojis: emojis)
            )
            singleLineMetaText2.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }

    func setupMultilineEditorMetaTextContent() {
        let content = (0..<100)
            .compactMap { _ in ":" + emojis.keys.randomElement()! + ":" }
            .joined(separator: " ")

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: "(MetaText, TextKit, Editor)\nEmoji only display on iOS 15" + content, emojis: emojis)
            )
            multilineEditorMetaText.configure(content: metaContent)
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
                document: MastodonContent(content: "(MetaLabel, TextKit 2, one line, emoji)" + content, emojis: emojis)
            )
            metaLabel.configure(content: metaContent)
        } catch {
            assertionFailure()
        }
    }
    
    func setupTextAreaContext() {
        let statusContent = """
        <p>(MetaTextArea, TextKit 2, Read-only, emoji):<br  /><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:<a href="https://mstdn.jp/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a> <a href="https://example.com/welcome/2021/02/01" rel="nofollow noopener noreferrer" target="_blank">https://example.com/welcome/<span class="invisible">2021/02/01</span></a></p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p>
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

    func setupLabelContent() {
        let content = (0..<4)
            .compactMap { _ in ":" + emojis.keys.randomElement()! + ":" }
            .joined(separator: " ")

        do {
            let metaContent = try MastodonMetaContent.convert(
                document: MastodonContent(content: "(UILabel, TextKit 2, no emoji) " + content + " end", emojis: emojis)
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

    func setupTextViewContext() {
        let statusContent = """
        <p>(UITextView, TextKit 2, Editor, emoji):<br><span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:<a href="https://mstdn.jp/tags/hashtag" class="mention hashtag" rel="tag">#<span>hashtag</span></a> <a href="https://example.com/welcome/2021/02/01" rel="nofollow noopener noreferrer" target="_blank">https://example.com/welcome/<span class="invisible">2021/02/01</span></a></p><p>Next paragraph Hello 你好 こんにちは 😂 :apple_inc: :apple_inc: :awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p><p>Next paragraph Hello 你好 こんにちは 😂:awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:</p>
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
}

// MARK: - MetaTextDelegate
extension MastodonStatusViewController: MetaTextDelegate {
    func metaText(_ metaText: MetaText, processEditing textStorage: MetaTextStorage) -> MetaContent? {
        guard metaText === self.multilineEditorMetaText else {
            assertionFailure()
            return nil
        }
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
            "smile_face": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Emoji_u263a.svg/40px-Emoji_u263a.svg.png",
        ]
    }

}
