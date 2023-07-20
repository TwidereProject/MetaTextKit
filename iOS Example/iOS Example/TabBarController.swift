//
//  TabBarController.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit

final class TabBarController: UITabBarController {
 
    let previewViewController = PreviewViewController()
    let mastodonStatusViewController = MastodonStatusViewController()
    let twitterStatusViewController = TwitterStatusViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewControllers: [UIViewController] = [
            UINavigationController(rootViewController: previewViewController),
            UINavigationController(rootViewController: mastodonStatusViewController),
            UINavigationController(rootViewController: twitterStatusViewController)
        ]
        previewViewController.title = "Preview"
        mastodonStatusViewController.title = "Mastodon"
        twitterStatusViewController.title = "Twitter"
        setViewControllers(viewControllers, animated: false)
    }
    
}
