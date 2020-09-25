//
//  TabBarViewController.swift
//  Kait
//
//  Created by Apple on 01/09/20.
//  Copyright © 2020 Sagar. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UINavigationBar.appearance().barTintColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        UITabBar.appearance().tintColor = UIColor().hexStringToUIColor(hex: AppManager.share.user.restaurant_color_code)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideBackButton()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == (self.tabBar.items!)[0]{
            //Do something if index is 0
            AppManager.share.selectedIndex = 0
        }
        else if item == (self.tabBar.items!)[1]{
            //Do something if index is 1
            AppManager.share.selectedIndex = 1
        }
    }
    
}
