//
//  PreviewContainer.swift
//  iOS Example
//
//  Created by MainasuK on 2023-07-20.
//

import SwiftUI
import SwiftUIIntrospect

struct PreviewContainer: View {
    
    @State var previewKind: PreviewKind = .twitter
    
    var body: some View {
        List {
            Section {
                switch previewKind {
                case .twitter:
                    ForEach(0..<10) { index in
                        Group {
                            cell(kind: previewKind, index: index)
                                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                    viewDimensions[.leading]
                                }
                        }   // end Group
                    }
                case .mastodon:
                    ForEach(0..<10) { index in
                        Group {
                            cell(kind: previewKind, index: index)
                                .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                                    viewDimensions[.leading]
                                }
                        }   // end Group
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
        .introspect(.list, on: .iOS(.v16, .v17)) { collectionView in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.headerMode = .supplementary
            configuration.headerTopPadding = .zero
            let layout = UICollectionViewCompositionalLayout.list(using: configuration)
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
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

extension PreviewContainer {
    private func cell(kind: PreviewKind, index: Int) -> MetaTextViewPreviewCell {
        switch kind {
        case .twitter:
            return MetaTextViewPreviewCell(viewModel: .twitter)
        case .mastodon:
            switch index % 2 {
            case 0:
                return MetaTextViewPreviewCell(viewModel: .mastodon)
            case 1:
                return MetaTextViewPreviewCell(viewModel: .mastodon1)
            default:
                return MetaTextViewPreviewCell(viewModel: .mastodon)
            }
        }
    }   // end func
}
