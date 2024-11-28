//
//  TextAreaViewController.swift
//  TextAreaViewController
//
//  Created by Cirno MainasuK on 2021-7-30.
//

import UIKit
import MetaTextKit
import MetaTextArea
import MastodonMeta

class TextAreaViewController: UIViewController {
    
    let textAreaView = MetaTextAreaView()
    
    let showLayerFramesBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.dashed"), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Text Area"
        navigationItem.rightBarButtonItems = [
            showLayerFramesBarButtonItem
        ]
        showLayerFramesBarButtonItem.target = self
        showLayerFramesBarButtonItem.action = #selector(TextAreaViewController.showLayerFramesBarButtonItemPressed(_:))
        
        textAreaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textAreaView)
        NSLayoutConstraint.activate([
            textAreaView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            textAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: textAreaView.trailingAnchor),
        ])
        
        textAreaView.layer.masksToBounds = true
        textAreaView.backgroundColor = .systemOrange.withAlphaComponent(0.5)
        
        let line = #"Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine. <span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> 😂 :awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:"#

        let metaContent = try! MastodonMetaContent.convert(
            document: MastodonContent(content: line, emojis: emojis)
        )
        textAreaView.configure(content: metaContent)
    }
    
}

extension TextAreaViewController {
    @objc private func showLayerFramesBarButtonItemPressed(_ sender: UIBarButtonItem) {
        #if DEBUG
        MetaTextAreaView.showLayerFrames.toggle()
        #endif
        
        textAreaView.textLayoutManager.textViewportLayoutController.layoutViewport()
    }
}

extension TextAreaViewController {
    var emojis: [String: String] {
        [
            "apple_inc": "https://media.mstdn.jp/custom_emojis/images/000/002/171/original/b848520ba07a354c.png",
            "awesome": "https://media.mstdn.jp/custom_emojis/images/000/002/757/original/3e0e01274120ad23.png",
            "ablobattention": "https://media.mstdn.jp/custom_emojis/images/000/123/539/original/f3b1abf131a34b6c.png",
            "ablobcaramelldansen": "https://media.mstdn.jp/custom_emojis/images/000/120/885/original/75cb4f59948b69ce.png",
            "ablobattentionreverse": "https://media.mstdn.jp/custom_emojis/images/000/120/907/original/d0320f5180028c28.png",
            "smile_face": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Emoji_u263a.svg/40px-Emoji_u263a.svg.png",
        ]
    }

}
