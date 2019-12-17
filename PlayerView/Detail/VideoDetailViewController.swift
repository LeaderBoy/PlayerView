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
        navgationConfig()
    }
    
    func navgationConfig() {
        navigationController?.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        playerView?.stop()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
 
    func addPlayerView() {
        if playerView == nil {
            playerView = PlayerView()
            if let url = URL(string: model.url) {
                playerView!.prepare(url: url, in: videoContainerView)
            }
        }else {
            playerView!.translatesAutoresizingMaskIntoConstraints = false
            videoContainerView.addSubview(playerView!)
            playerView!.edges(to: videoContainerView)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }    
}

/// MARK: UINavigationControllerDelegate
extension VideoDetailViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.isKind(of: self.classForCoder) {
            navigationController.setNavigationBarHidden(true, animated: true)
        }else {
            navigationController.setNavigationBarHidden(false, animated: true)
        }
    }
}

