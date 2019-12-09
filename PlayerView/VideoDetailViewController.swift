//
//  VideoDetailViewController.swift
//  PlayerView
//
//  Created by 杨 on 2019/12/9.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class VideoDetailViewController: UIViewController {

    @IBOutlet weak var videoContainerView: UIView!
    
    var model : MovieModel!
    
    var playerView : PlayerView?
   
    convenience init(playerView : PlayerView?) {
        self.init(nibName:nil, bundle:nil)
        self.playerView = playerView
    }
    
    deinit {
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPlayerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.navigationBar.isHidden = false
        playerView?.stop()
    }
 
    func addPlayerView() {
        if playerView == nil {
            playerView = PlayerView()
        }
        
        if let url = URL(string: model.url) {
            playerView!.prepare(url: url, in: videoContainerView)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
}

