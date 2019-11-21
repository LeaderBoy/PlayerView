//
//  ViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let urlString = "http://lessimore.cn/Meet%20iPhone%20X%20%E2%80%94%20Apple.mp4"
    
    @IBOutlet weak var playerView: PlayerView!
    
    var reachability = Reachability.forInternetConnection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerViewPlay()
        reachability?.statusDidChanged = { status in
            print(status)
        }
        // Do any additional setup after loading the view.
    }
    
    func playerViewPlay() {
        if let url = URL(string: urlString) {
            playerView.prepare(url: url)
        }
    }


}

