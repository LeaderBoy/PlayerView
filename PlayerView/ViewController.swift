//
//  ViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/20.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

//    let urlString = "http://lessimore.cn/Meet%20iPhone%20X%20%E2%80%94%20Apple.mp4"
    
    let urlString = "http://lessimore.cn/iPhone%20X%20%20-%20Apple%20%20-%20cnBetaCOM.mp4"
    
    @IBOutlet weak var playerView: PlayerView!
    
    @IBOutlet weak var containerView: UIView!
    
    var reachability = Reachability.forInternetConnection()
    
    lazy var delegate : Transition = {
        let animator = Animator(with: playerView)
        let d = Transition(animator: animator)
        return d
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerViewPlay()
        reachability?.statusDidChanged = { status in
            print(status)
        }
        view.backgroundColor = .green
        // Do any additional setup after loading the view.
    }
    
    func playerViewPlay() {
        if let url = URL(string: urlString) {
            playerView.prepare(url: url)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        if playerView != nil {
            return playerView.shouldStatusBarHidden
        }
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let player = PlayerViewController()
        player.modalPresentationStyle = .fullScreen
        player.transitioningDelegate = delegate
        present(player, animated: true, completion: nil)
    }


}

