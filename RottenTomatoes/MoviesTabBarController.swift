//
//  MoviesTabBarController.swift
//  RottenTomatoes
//
//  Created by Matthew Goo on 9/19/15.
//  Copyright © 2015 mattgoo. All rights reserved.
//

import UIKit

class MoviesTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        let currentViewController = self.selectedViewController as? MoviesViewController
        
        var category = "boxOffice"
        if self.selectedIndex == 0 {
            category = "dvd"
        }
        currentViewController?.category = category
        print("changed item, \(item), \(category)")
    }
    


}
