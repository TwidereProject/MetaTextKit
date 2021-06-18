//
//  TabBarController.swift
//  iOS Example
//
//  Created by MainasuK Cirno on 2021-6-7.
//

import UIKit

final class TabBarController: UITabBarController {
 
    let viewController = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewControllers: [UIViewController] = [
            UINavigationController(rootViewController: viewController),
        ]
        setViewControllers(viewControllers, animated: false)
    }
    
}
