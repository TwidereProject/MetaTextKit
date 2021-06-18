//
//  ViewController.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit
import MetaTextView

class ViewController: UIViewController {
    
    let metaText = MetaText()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "MetaTextView"
        
        metaText.textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(metaText.textView)
        NSLayoutConstraint.activate([
            metaText.textView.topAnchor.constraint(equalTo: view.topAnchor),
            metaText.textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            metaText.textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            metaText.textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

}
