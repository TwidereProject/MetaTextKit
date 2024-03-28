//
//  TwitterMetaTests+RichText.swift
//  
//
//  Created by MainasuK on 2024-03-27.
//

import Foundation
import XCTest
import TwitterText
@testable import TwitterMeta

extension MetaTextViewTests {
    func testTwitterContentRichText() {
        // https://twitter.com/thefireflyapp/status/1762157161520525435
        let text = """
        GM ETH Denver.\n\n1 million $DEGEN up for grabs this week \nfor the @SporkDao / @EthereumDenver community\n\nCollect our EthDenver NFT 👇\nhttps://t.co/AEupjKN7xC\n\n✅ Early Access to Firefly\n🆓 Free Farcaster Sign Up (1 week only!)\n🤑 Chance to win up to 1M $DEGEN from Lucky Drops
        """
        
        let content = TwitterContent(
            content: text,
            urlEntities: [
                .init(url: "https://t.co/AEupjKN7xC", expandedURL: "https://zora.co/collect/base:0x577294402ba4679b6ba4a24b8e03ce9d0c728e72/1", displayURL: "zora.co/collect/base:0…")
            ],
            richTextTags: [
                .init(range: NSRange(location: 16, length: 26 - 16), types: [.bold]),   // 1 million
                .init(range: NSRange(location: 32, length: 56 - 32), types: [.bold]),   // up for grabs this week
                .init(range: NSRange(location: 57, length: 65 - 57), types: [.bold]),   // for the
                .init(range: NSRange(location: 74, length: 77 - 74), types: [.bold]),   // /
                .init(range: NSRange(location: 92, length: 102 - 92), types: [.bold]),  // community   
            ]
        )
        let metaContent = TwitterMetaContent.convert(
            document: content,
            urlMaximumLength: 26,
            twitterTextProvider: SwiftTwitterTextProvider(),
            useParagraphMark: false
        )
        print(metaContent)

        // useParagraphMark: true
        // TwitterMetaContent(original: "GM ETH Denver.
        // 1 million $DEGEN up for grabs this week
        // for the @SporkDao / @EthereumDenver community
        // Collect our EthDenver NFT 👇
        // https://t.co/AEupjKN7xC
        // ✅ Early Access to Firefly
        // 🆓 Free Farcaster Sign Up (1 week only!)
        // 🤑 Chance to win up to 1M $DEGEN from Lucky Drops", trimmed: "GM ETH Denver.
        // 1 million $DEGEN up for grabs this week
        // for the @SporkDao / @EthereumDenver community
        // Collect our EthDenver NFT 👇
        // zora.co/collect/base:0…
        // ✅ Early Access to Firefly
        // 🆓 Free Farcaster Sign Up (1 week only!)
        // 🤑 Chance to win up to 1M $DEGEN from Lucky Drops", entities: [{{15, 10}, 1 million , style, {{25, 6}, $DEGEN, cashtag, {{31, 24},  up for grabs this week , style, {{56, 8}, for the , style, {{64, 9}, @SporkDao, mention, {{73, 3},  / , style, {{76, 15}, @EthereumDenver, mention, {{91, 10},  community, style, {{131, 23}, https://zora.co/collect/base:0x577294402ba4679b6ba4a24b8e03ce9d0c728e72/1, url, {{248, 6}, $DEGEN, cashtag])
        
        // useParagraphMark: false
        // TwitterMetaContent(original: "GM ETH Denver.\n\n1 million $DEGEN up for grabs this week \nfor the @SporkDao / @EthereumDenver community\n\nCollect our EthDenver NFT 👇\nhttps://t.co/AEupjKN7xC\n\n✅ Early Access to Firefly\n🆓 Free Farcaster Sign Up (1 week only!)\n🤑 Chance to win up to 1M $DEGEN from Lucky Drops", trimmed: "GM ETH Denver.\n\n1 million $DEGEN up for grabs this week \nfor the @SporkDao / @EthereumDenver community\n\nCollect our EthDenver NFT 👇\nzora.co/collect/base:0…\n\n✅ Early Access to Firefly\n🆓 Free Farcaster Sign Up (1 week only!)\n🤑 Chance to win up to 1M $DEGEN from Lucky Drops", entities: [{{16, 10}, 1 million , style, {{26, 6}, $DEGEN, cashtag, {{32, 24},  up for grabs this week , style, {{57, 8}, for the , style, {{65, 9}, @SporkDao, mention, {{74, 3},  / , style, {{77, 15}, @EthereumDenver, mention, {{92, 10},  community, style, {{133, 23}, https://zora.co/collect/base:0x577294402ba4679b6ba4a24b8e03ce9d0c728e72/1, url, {{251, 6}, $DEGEN, cashtag])
    }
}
