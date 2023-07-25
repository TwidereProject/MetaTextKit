//
//  MetaTextViewPreviewCell.swift
//  iOS Example
//
//  Created by MainasuK on 2023-07-20.
//


import SwiftUI
import MetaTextKit
import TwitterMeta
import MastodonMeta

struct MetaTextViewPreviewCell: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        MetaTextViewRepresentable(metaContent: viewModel.metaContent)
    }
}

extension MetaTextViewPreviewCell {
    class ViewModel: ObservableObject {
        
        // output
        @Published public private(set) var metaContent: MetaContent = PlaintextMetaContent(string: "")
        
        
        init() {
            // end init
        }
    }
}

extension MetaTextViewPreviewCell.ViewModel {
    static var twitter: MetaTextViewPreviewCell.ViewModel {
        let viewModel = MetaTextViewPreviewCell.ViewModel()
        let text = """
        Hello 你好 こんにちは 😂
        This is an example post for Twitter. This line is long enough to demonstrate the different spacing for paragraphs and lines.
        @mention #hashtag https://twitter.com/ABCDEFG
        """
        let content = TwitterContent(content: text)
        let metaContent = TwitterMetaContent.convert(
            content: content,
            urlMaximumLength: 0,
            twitterTextProvider: OfficialTwitterTextProvider()
        )
        viewModel.metaContent = metaContent
        return viewModel
    }
    
    static var mastodon: MetaTextViewPreviewCell.ViewModel {
        let viewModel = MetaTextViewPreviewCell.ViewModel()
        let emojis: [String: String] = {
            [
                "apple_inc": "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png",
                "awesome": "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png",
                "ablobattention": "https://media.mstdn.jp/custom_emojis/images/000/123/539/original/f3b1abf131a34b6c.png",
                "ablobcaramelldansen": "https://media.mstdn.jp/custom_emojis/images/000/120/885/original/75cb4f59948b69ce.png",
                "ablobattentionreverse": "https://media.mstdn.jp/custom_emojis/images/000/120/907/original/d0320f5180028c28.png",
                "sabakan": "https://media.mstdn.jp/custom_emojis/images/000/009/467/original/2b20a39ee04c39f5.png",
            ]
        }()
        let text = """
        <p>:sabakan: <a href=\"https://mastodon.social/tags/Mastodon\" class=\"mention hashtag\" rel=\"nofollow noopener noreferrer\" target=\"_blank\">#<span>Mastodon</span></a> 3.5.3 has just been <em>released</em> with multiple <strong>security</strong> fixes, as well <strong>as a <em>couple</em> cool</strong> improvements!</p><p><a href=\"https://github.com/mastodon/mastodon/releases/tag/v3.5.3\" rel=\"nofollow noopener noreferrer\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">github.com/mastodon/mastodon/r</span><span class=\"invisible\">eleases/tag/v3.5.3</span></a></p><p>A 3.4.8 <code>backport</code>= is available <u>for</u> those who haven\'t made the <del>jump</del> to 3.5 yet.</p><pre><code>function helloWorld() {\n  console.log("Hello, world!");\n}</code></pre>
        """
        let content = MastodonContent(content: text, emojis: emojis)
        do {
            let metaContent = try MastodonMetaContent.convert(document: content)
            viewModel.metaContent = metaContent
            return viewModel
        } catch {
            return viewModel
        }
    }
    
    static var mastodon1: MetaTextViewPreviewCell.ViewModel {
        let viewModel = MetaTextViewPreviewCell.ViewModel()
        let emojis: [String: String] = {
            [
                "apple_inc": "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png",
                "awesome": "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png",
                "ablobattention": "https://media.mstdn.jp/custom_emojis/images/000/123/539/original/f3b1abf131a34b6c.png",
                "ablobcaramelldansen": "https://media.mstdn.jp/custom_emojis/images/000/120/885/original/75cb4f59948b69ce.png",
                "ablobattentionreverse": "https://media.mstdn.jp/custom_emojis/images/000/120/907/original/d0320f5180028c28.png",
                "sabakan": "https://media.mstdn.jp/custom_emojis/images/000/009/467/original/2b20a39ee04c39f5.png",
            ]
        }()
        let text = """
        <p>markdown test post, don\'t mind me</p><h1>h1</h1><h2>h2</h2><h3>h3</h3><h4>h4</h4><h5>h5</h5><h6>h6</h6><p>Test with:</p><ul><li>lists</li><li><del>strikethrough</del></li><li><em>emphasis</em></li><li><strong>strong emphasis</strong></li><li><u>underlines</u></li><li><code>inline code quote</code></li><li>and more<ul><li>nest list item<ul><li>nest x 2 list item</li></ul></li></ul></li></ul><ol><li>first</li><li>second</li><li>third<ol><li>This is 3.1</li><li>This is 3.2</li></ol></li></ol><pre><code>def foo:\n    return \'bar\'</code></pre><p>This is <code>inline</code> code tag</p><blockquote><p>blah blah</p></blockquote>
        """
        let content = MastodonContent(content: text, emojis: emojis)
        do {
            let metaContent = try MastodonMetaContent.convert(document: content)
            viewModel.metaContent = metaContent
            return viewModel
        } catch {
            return viewModel
        }
    }
}

struct MetaTextViewPreviewCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            MetaTextViewPreviewCell(viewModel: .twitter)
            MetaTextViewPreviewCell(viewModel: .twitter)
            MetaTextViewPreviewCell(viewModel: .twitter)
            MetaTextViewPreviewCell(viewModel: .twitter)
            Spacer()
        }
        .listStyle(.plain)
    }
}
