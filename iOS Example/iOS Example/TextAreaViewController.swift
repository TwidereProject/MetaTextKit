//
//  TextAreaViewController.swift
//  TextAreaViewController
//
//  Created by Cirno MainasuK on 2021-7-30.
//

import UIKit
import MetaTextKit

class TextAreaViewController: UIViewController {
    
    let textAreaView = TextAreaView()
    
    let showLayerFramesBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.dashed"), style: .plain, target: nil, action: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        textAreaView.backgroundColor = .gray
        
        let line = #"Hello, World! I know nothing in the world that has as much power as a word. Sometimes I write one, and I look at it, until it begins to shine. <span class="h-card"><a class="u-url mention" href="https://example.com/users/@username" rel="nofollow noopener noreferrer" target="_blank">@<span>username</span></a></span> 😂 :awesome: :ablobattention: :ablobcaramelldansen: :ablobattentionreverse:"#
        let string = Array(repeating: line, count: 3).joined(separator: "\u{2029}")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attributedString = NSAttributedString(string: string, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label,
            .paragraphStyle: paragraphStyle
        ])
        textAreaView.textContentStorage.textStorage?.setAttributedString(attributedString)
    }
    
}

extension TextAreaViewController {
    @objc private func showLayerFramesBarButtonItemPressed(_ sender: UIBarButtonItem) {
        textAreaView.showLayerFrames.toggle()
        textAreaView.textLayoutManager.textViewportLayoutController.layoutViewport()
    }
}
