//
//  TopNavigationViewController.swift
//  QiitaCollection
//
//  Created by ANZ on 2015/02/07.
//  Copyright (c) 2015年 anz. All rights reserved.
//

import UIKit

class TopNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.textNavigationBar()]
        self.navigationBar.barTintColor = UIColor.backgroundNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
