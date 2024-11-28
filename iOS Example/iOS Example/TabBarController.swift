//
//  TabBarController.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit

final class TabBarController: UITabBarController {
 
    let mastodonStatusViewController = MastodonStatusViewController()
    let twitterStatusViewController = TwitterStatusViewController()
    let textAreaViewController = TextAreaViewController()
    let swiftUIViewController = SwiftUIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let viewControllers: [UIViewController] = [
            UINavigationController(rootViewController: mastodonStatusViewController),
            UINavigationController(rootViewController: twitterStatusViewController),
            UINavigationController(rootViewController: textAreaViewController),
            UINavigationController(rootViewController: swiftUIViewController),
        ]
        
        setViewControllers(viewControllers, animated: false)

        tabBar.backgroundColor = .systemBackground

        tabBar.items![0].image = UIImage(systemName: "heart.text.square")
        tabBar.items![1].image = UIImage(systemName: "doc.text.below.ecg")
        tabBar.items![2].image = UIImage(systemName: "doc.text")
        tabBar.items![3].image = UIImage(systemName: "list.bullet.below.rectangle")

        tabBar.items![0].title = "Mastodon"
        tabBar.items![1].title = "Twitter"
        tabBar.items![2].title = "TextArea"
        tabBar.items![3].title = "SwiftUI"
    }
    
}
