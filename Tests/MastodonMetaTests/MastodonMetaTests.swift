//
//  MastodonMetaTests.swift
//  
//
//  Created by Cirno MainasuK on 2021-6-27.
//

import XCTest
import Foundation
@testable import MastodonMeta

final class MetaTextViewTests: XCTestCase {

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
            //debugPrint(metaContent.entities)
        }
    }

    func testPerformanceParseDocumentContent() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
