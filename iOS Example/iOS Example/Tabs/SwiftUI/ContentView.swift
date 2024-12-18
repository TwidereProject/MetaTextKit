//
//  ContentView.swift
//  iOS Example
//
//  Created by MainasuK on 2024-11-28.
//  Copyright © 2024 MetaTextKit. All rights reserved.
//

import SwiftUI
import TwitterMeta

struct ContentView: View {

    @State var textEditorContent = "Hello, World!"

    let metaContent: MetaContent

    init() {
        let content = """
        Hello, World! @username #hashtag awesome smile_face hi apple_inc apple_inc. Hello, World! @username #hashtag awesome smile_face hi apple_inc apple_inc. Hello, World! @username #hashtag awesome smile_face hi apple_inc apple_inc
        The paragraph 2 is from this line. The paragraph 2 is from this line. The paragraph 2 is from this line. The paragraph 2 is from this line. The paragraph 2 is from this line. The paragraph 2 is from this line.
        The paragraph 3 is from this line. The paragraph 3 is from this line. The paragraph 3 is from this line. The paragraph 3 is from this line. The paragraph 3 is from this line. The paragraph 3 is from this line.
        """
        let text = TwitterContent(
            content: content,
            urlEntities: [],
            inlineMedia: {
                var media: [TwitterContent.InlineMedia] = []
                media.append(TwitterContent.InlineMedia(
                    index: 100,
                    mediaID: "001",
                    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/The_Earth_seen_from_Apollo_17.jpg/1280px-The_Earth_seen_from_Apollo_17.jpg",
                    previewURL: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/97/The_Earth_seen_from_Apollo_17.jpg/1280px-The_Earth_seen_from_Apollo_17.jpg",
                    size: CGSize(width: 1280, height: 1281),
                    mediaType: .photo
                ))
                return media
            }()
        )
        let dict: [String: URL] = [
            "apple_inc": "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png",
            "awesome": "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png",
            "ablobattention": "https://media.mstdn.jp/custom_emojis/images/000/123/539/original/f3b1abf131a34b6c.png",
            "ablobcaramelldansen": "https://media.mstdn.jp/custom_emojis/images/000/120/885/original/75cb4f59948b69ce.png",
            "ablobattentionreverse": "https://media.mstdn.jp/custom_emojis/images/000/120/907/original/d0320f5180028c28.png",
            "smile_face": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Emoji_u263a.svg/40px-Emoji_u263a.svg.png",
        ].compactMapValues { URL(string: $0) }
        let metaContent = TwitterMetaContent.convert(
            document: text,
            urlMaximumLength: 999,
            twitterTextProvider: OfficialTwitterTextProvider(),
            addtionalMetaProvider: InlineIconMetaProvider(
                option: .keyword,
                context: InlineIconMetaProvider.Context(dict: dict)
            )
        )
        self.metaContent = metaContent
    }

    var body: some View {
        List {
            Section {
                Text("Hello, World!")
            } header: {
                Text("SwiftUI.Text")
                    .textCase(nil)
            } footer: {
                Text("one or multi-line, read-only")
            }

            Section {
                TextEditor(text: $textEditorContent)
            } header: {
                Text("SwiftUI.TextEditor")
                    .textCase(nil)
            } footer: {
                Text("multi-line, editable")
            }
            Section {
                TextViewRepresentable(
                    metaContent: metaContent,
                    width: 100,
                    configuration: TextViewRepresentable.Configuration(
                        isSelectable: true,
                        paragraphStyle: {
                            let paragraphStyle: NSMutableParagraphStyle = {
                                let style = NSMutableParagraphStyle()
                                style.lineSpacing = 3.5
                                style.paragraphSpacing = -3
                                return style
                            }()
                            return paragraphStyle
                        }()
                    )
                ) { meta in
                    print("tap meta: \(meta)")
                }
            } header: {
                Text("UIKit.TextView + UIViewRepresentable")
                    .textCase(nil)
            } footer: {
                Text("multi-line, selectable")
            }
        }
        .listStyle(.insetGrouped)
    }
}
