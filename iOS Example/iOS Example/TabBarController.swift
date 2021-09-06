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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let viewControllers: [UIViewController] = [
            UINavigationController(rootViewController: mastodonStatusViewController),
            UINavigationController(rootViewController: twitterStatusViewController)
        ]
        
        setViewControllers(viewControllers, animated: false)
        
        tabBar.items![0].image = UIImage(systemName: "heart.text.square")
        tabBar.items![1].image = UIImage(systemName: "doc.text.below.ecg")
        
        tabBar.items![0].title = "Mastodon"
        tabBar.items![1].title = "Twitter"
    }
    
}
