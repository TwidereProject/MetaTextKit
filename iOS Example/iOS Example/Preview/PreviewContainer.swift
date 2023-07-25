//
//  PreviewContainer.swift
//  iOS Example
//
//  Created by MainasuK on 2023-07-20.
//

import SwiftUI

struct PreviewContainer: View {
    
    @State var previewKind: PreviewKind = .twitter
    
    var body: some View {
        List {
            Section {
                ForEach(0..<10) { _ in
                    Group {
                        switch previewKind {
                        case .twitter:
                            MetaTextViewPreviewCell(viewModel: .twitter)
                                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                    viewDimensions[.leading]
                                }
                        case .mastodon:
                            MetaTextViewPreviewCell(viewModel: .mastodon)
                                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                    viewDimensions[.leading]
                                }
                        }
                    }
                }
            } header: {
                Picker("Preview Kind", selection: $previewKind) {
                    ForEach(PreviewKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .listStyle(.plain)
    }
}

extension PreviewContainer {
    enum PreviewKind: CaseIterable, Hashable, Identifiable {
        var id: Self { self }
        case twitter
        case mastodon
        
        var title: String {
            switch self {
            case .twitter: return "Twitter"
            case .mastodon: return "Mastodon"
            }
        }
    }
}
