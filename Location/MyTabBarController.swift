//
//  MyTabBarController.swift
//  Location
//
//  Created by MARC on 4/9/20.
//  Copyright © 2020 MARC. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }
}
