//
//  MetaTextViewPreviewCell.swift
//  iOS Example
//
//  Created by MainasuK on 2023-07-20.
//


import SwiftUI
import MetaTextKit
import TwitterMeta

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
        @username: Hello 你好 こんにちは 😂😂😂 #hashtag https://twitter.com/ABCDEFG
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
