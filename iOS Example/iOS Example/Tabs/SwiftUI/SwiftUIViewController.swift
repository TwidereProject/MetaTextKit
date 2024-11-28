//
//  SwiftUIViewController.swift
//  iOS Example
//
//  Created by MainasuK on 2024-11-28.
//  Copyright © 2024 MetaTextKit. All rights reserved.
//

import UIKit
import SwiftUI

final class SwiftUIViewController: UIViewController {

}

extension SwiftUIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "SwiftUI"

        let hostingController = UIHostingController(rootView: ContentView())
        addChild(hostingController)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.willMove(toParent: self)
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

}
