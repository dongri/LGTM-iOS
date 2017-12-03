//
//  ViewController.swift
//  LGTM
//
//  Created by Dongri Jin on 2017/11/29.
//  Copyright © 2017 Dongri Jin. All rights reserved.
//

import UIKit

class ViewController: UITabBarController {

    var tabHomeController: UINavigationController!
    var tabSubmitController: UINavigationController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tabHomeController = UINavigationController(rootViewController: HomeViewController ())
        tabHomeController.tabBarItem = UITabBarItem(title: "List", image: UIImage(named: "list"), tag: 1)

        tabSubmitController = UINavigationController(rootViewController: SubmitViewController ())
        tabSubmitController.tabBarItem = UITabBarItem(title: "Submit", image: UIImage(named: "submit"), tag: 2)

        let tabs = NSArray(objects: tabHomeController, tabSubmitController!)
        self.setViewControllers(tabs as? [UIViewController], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

