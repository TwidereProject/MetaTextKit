//
//  MastodonMetaTests.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-27.
//

import XCTest
import Foundation
import Fuzi
@testable import MastodonMeta

final class MastodonMetaTests: XCTestCase {

    struct Emoji: Codable {
        let shortcode: String
        let url: String
        let staticURL: String
        let visibleInPicker: Bool

        enum CodingKeys: String, CodingKey {
            case shortcode
            case url
            case staticURL = "static_url"
            case visibleInPicker = "visible_in_picker"
        }

    }

    func testPerformanceParseTextContent() throws {
        guard let url = Bundle.module.url(forResource: "custom-emojis", withExtension: "json"),
              let emojisData = try? Data(contentsOf: url),
              let emojisJSON = try? JSONDecoder().decode([Emoji].self, from: emojisData) else {
            XCTFail()
            return
        }

        var emojis: MastodonContent.Emojis = [:]
        for emoji in emojisJSON {
            emojis[emoji.shortcode] = emoji.url
        }

        let textContent = Array(repeating: "hello @alice, welcome to my #party. :awesome: https://example.com.", count: 100).joined(separator: "\n")
        let content = MastodonContent(
            content: textContent,
            emojis: emojis
        )

        self.measure {
            let metaContent = MastodonMetaContent.convert(text: content)
        }
    }

    func testPerformanceParseDocumentContent() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

extension MastodonMetaTests {
    func testMastodonParseRichText() throws {
        let text = """
        <p>markdown test post, don\'t mind me</p><h1>h1</h1><h2>h2</h2><h3>h3</h3><h4>h4</h4><h5>h5</h5><h6>h6</h6><p>Test with:</p><ul><li>lists</li><li><del>strikethrough</del></li><li><em>emphasis</em></li><li><strong>strong emphasis</strong></li><li><u>underlines</u></li><li><code>inline code quote</code></li><li>and more<ul><li>nest list item<ul><li>nest x 2 list item</li></ul></li></ul></li></ul><ol><li>first</li><li>second</li><li>third<ol><li>This is 3.1</li><li>This is 3.2</li></ol></li></ol><pre><code>def foo:\n    return \'bar\'</code></pre><p>This is <code>inline</code> code tag</p><blockquote><p>blah blah</p></blockquote>
        """
        let content = MastodonContent(content: text, emojis: [:])
        try content.preprocess()
    }
}
