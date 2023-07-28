//
//  MastodonMetaTests+Mastodon.swift
//  
//
//  Created by MainasuK on 2023-07-28.
//

import Foundation
@testable import MastodonMeta

extension MastodonMetaTests {
    func testMastodonContentPreprocessor() throws {
        let text = """
        <p>markdown test post, don\'t mind me</p><h1>h1</h1><h2>h2</h2><h3>h3</h3><h4>h4</h4><h5>h5</h5><h6>h6</h6><p>Test with:</p><ul><li>lists</li><li><del>strikethrough</del></li><li><em>emphasis</em></li><li><strong>strong emphasis</strong></li><li><u>underlines</u></li><li><code>inline code quote</code></li><li>and more<ul><li>nest list item<ul><li>nest x 2 list item</li></ul></li></ul></li></ul><ol><li>first</li><li>second</li><li>third<ol><li>This is 3.1</li><li>This is 3.2</li></ol></li></ol><pre><code>def foo:\n    return \'bar\'</code></pre><p>This is <code>inline</code> code tag</p><blockquote><p>blah blah</p></blockquote>
        """
        let content = MastodonContent(content: text, emojis: [:])
        let document = try content.preprocess()
        let body = document.body!
        print(body.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).rawRepresent)
    }
}
