//
//  PreviewContainer.swift
//  iOS Example
//
//  Created by MainasuK on 2023-07-20.
//

import SwiftUI

struct PreviewContainer: View {
    var body: some View {
        List {
            Section {
                ForEach(0..<10) { _ in
                    MetaTextViewPreviewCell(viewModel: .twitter)
                        .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                            viewDimensions[.leading]
                        }
                }
            } header: {
                VStack {
                    Text("Twitter")
                }
                .ignoresSafeArea(.container, edges: .top)
            }
        }
        .listStyle(.plain)
    }
}
