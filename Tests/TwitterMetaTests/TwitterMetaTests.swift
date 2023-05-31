//
//  TwitterMetaTests.swift
//  
//
//  Created by MainasuK on 2023/5/31.
//

import Foundation
import XCTest
@testable import TwitterMeta
import TwitterText

final class MetaTextViewTests: XCTestCase {
 
    func testTwitterContentEmbed() {
        let text = """
        ／
        #セブンイレブン 限定キャンペーン
        店頭でNetflixのバリアブルカードを買うと⁉️
        ＼
        
        話題の #ステルス家電
        『スツールフットマッサージャー』が当たる
        足を癒すマッサージ器としてだけでなく
        スツール、オットマンとしてインテリアの一部にも✨
        
        応募条件等は👉https://t.co/rXHZwEKY49
        
        #ネトフリ
        """
        let urlEntities: [TwitterContent.URLEntity] = [
            .init(url: "https://t.co/rXHZwEKY49", expandedURL: "https://vdpro.jp/sej.netflix6.sns/", displayURL: "vdpro.jp/sej.netflix6.s…"),
            .init(url: "https://t.co/0oK7UeywCn", expandedURL: "https://twitter.com/711SEJ/status/1634089203196899328/photo/1", displayURL: "pic.twitter.com/0oK7UeywCn"),
        ]
        let content = TwitterContent(content: text, urlEntities: urlEntities)
        let metaContent = TwitterMetaContent.convert(
            document: content,
            urlMaximumLength: 26,
            twitterTextProvider: SwiftTwitterTextProvider()
        )
        
        let translatedText = """
        ／
        #セブンイレブン独家优惠
        在店内购买 Netflix 可变卡！ ?️
        ＼
        
        趋势#ステルス家電
        赢得“凳子足按摩器”
        不仅作为按摩器来治愈脚部
        也是✨内部的一部分作为凳子，奥斯曼帝国
        
        👉https://t.co/rXHZwEKY49 有哪些申请要求
        
        #ネトフリ
        """
        let translatedContent = TwitterContent(content: translatedText, urlEntities: urlEntities)
        let embeddedMetaContent = translatedContent.embed(entities: metaContent.entities)
        
        print(embeddedMetaContent)
    }
}
