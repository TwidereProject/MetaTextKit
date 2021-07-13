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
        
        let viewControllers: [UIViewController] = [
            UINavigationController(rootViewController: mastodonStatusViewController),
            UINavigationController(rootViewController: twitterStatusViewController)
        ]
        setViewControllers(viewControllers, animated: false)
    }
    
}
