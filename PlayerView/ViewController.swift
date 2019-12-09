//
//  ViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit
import Combine

class ViewController: UIViewController {
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
}



