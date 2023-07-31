//
//  MastodonMetaTests+Benchmark.swift
//  
//
//  Created by MainasuK on 2023-07-26.
//

import Foundation
import Fuzi
import SwiftSoup
import XCTest

extension MastodonMetaTests {
    
    // ~ 0.06s
    func testPerformanceParseDocumentContent_Fuzi() throws {
        let documents = try self.documents()
        self.measure {
            for document in documents {
                do {
                    let html = try HTMLDocument(string: document)
                    guard let body = html.body else { return }
                    _ = recursion(element: body)
                } catch {
                    XCTFail()
                }
            }   // end for in
        }
    }
    
    // ~ 2s
    func testPerformanceParseDocumentContent_SwiftSoup() throws {
        let documents = try self.documents()
        self.measure {
            for document in documents {
                do {
                    let html = try SwiftSoup.parse(document)
                    guard let body = html.body() else { return }
                    _ = recursion(element: body)
                } catch {
                    XCTFail()
                }
            }   // end for in
        }
    }
    
}

extension MastodonMetaTests {
        
    // ~ 0.007s
    func testPerformanceParseDocumentContent_Fuzi_posts() throws {
        let documents = try self.posts()
        self.measure {
            for document in documents {
                do {
                    let html = try HTMLDocument(string: document)
                    guard let body = html.body else { return }
                    _ = recursion(element: body)
                } catch {
                    XCTFail()
                }
            }   // end for in
        }
    }
    
    // ~ 0.1s
    func testPerformanceParseDocumentContent_SwiftSoup_posts() throws {
        let documents = try self.posts()
        self.measure {
            for document in documents {
                do {
                    let html = try SwiftSoup.parse(document)
                    guard let body = html.body() else { return }
                    _ = recursion(element: body)
                } catch {
                    XCTFail()
                }
            }   // end for in
        }
    }
    
}

extension MastodonMetaTests {
    private func document(name: String) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: "html") else {
            XCTFail()
            return ""
        }
        
        let document = try String(contentsOf: url)
        return document
    }
    
    private func documents() throws -> [String] {
        let documents = try [
            "apple-iPad",
            "apple-iPhone",
            "apple-mac",
            "apple-vision-pro",
            "apple",
        ].map { try document(name: $0) }
        return documents
    }
    
    private func posts() throws -> [String] {
        let text = """
        <p>markdown test post, don\'t mind me</p><h1>h1</h1><h2>h2</h2><h3>h3</h3><h4>h4</h4><h5>h5</h5> h6 <p>Test with:</p><ul><li>lists</li><li><del>strikethrough</del></li><li><em>emphasis</em></li><li><strong>strong emphasis</strong></li><li><u>underlines</u></li><li><code>inline code quote</code></li><li>and more<ul><li>nest list item<ul><li>nest x 2 list item</li></ul></li></ul></li></ul><ol><li>first</li><li>second</li><li>third<ol><li>This is 3.1</li><li>This is 3.2</li></ol></li></ol><pre><code>def foo:\n    return \'bar\'</code></pre><p>This is <code>inline</code> code tag</p><blockquote><p>blah blah</p></blockquote>
        """
        return Array(repeating: text, count: 100)
    }
}

extension MastodonMetaTests {
    private func recursion(element: Fuzi.XMLElement) -> String {
        var content = element.stringValue
        for child in element.children {
            let _content = recursion(element: child)
            content += _content
        }
        return content
    }
    
    private func recursion(element: SwiftSoup.Element) -> String {
        var content = try! element.text(trimAndNormaliseWhitespace: false)
        for child in element.children() {
            let _content = recursion(element: child)
            content += _content
        }
        return content
    }
}
