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
    
    var originalOffset = CGPoint.zero
    
    var willEnterFullScreen = false
    
    var delegate : Transition!
    
    @IBOutlet weak var tableView: UITableView!
    let playerVC = PlayerViewController()
    lazy var playerView = PlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.delegate = self
        setupTableView()
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        if willEnterFullScreen {
            UIView.animate(withDuration: playerAnimationTime) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.delaysContentTouches = false
        let nib = UINib(nibName: "VideoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "VideoCell")
    }
    
    func playerViewPlay() {
        if let url = URL(string: urlString) {
            playerView.prepare(url: url)
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
            
            //playerView.shouldStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if newCollection.verticalSizeClass == .regular {
            tableView.contentOffset = originalOffset
        }else {
            originalOffset = tableView.contentOffset
            print(originalOffset)
        }
        
        print("执行")
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size, with: coordinator)
//        let offset = tableView.contentOffset
//        let height  = tableView.bounds.size.height
//
//        let index     = round(offset.y / height)
//        let newOffset = CGPoint(x: offset.x, y: index * size.height)
//
//        tableView.setContentOffset(newOffset, animated: false)
//
//        coordinator.animate(alongsideTransition: { (context) in
//            self.tableView.reloadData()
//            self.tableView.setContentOffset(newOffset, animated: false)
//        }, completion: nil)
//    }
    
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        tableView.contentOffset = originalOffset
//    }
    
}

extension ViewController : PlayerDelegate {
    func playerWillExitFullScreen() {
        willEnterFullScreen = false
        playerVC.dismiss(animated: true, completion: nil)
    }
    func playerWillEnterFullScreen() {
        willEnterFullScreen = true
        playerVC.modalPresentationStyle = .fullScreen
        let animator = Animator(with: playerView)
        let delegate = Transition(animator: animator)
        self.delegate = delegate
        playerVC.transitioningDelegate = delegate
        present(playerVC, animated: true) {
            self.playerVC.view.backgroundColor = .clear
        }
    }
}

extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! VideoCell
        cell.label.text = "\(indexPath.row)"
        cell.delegate = self
        return cell
    }
    
}

extension ViewController : CellClick {
    func click(at container: UIView) {
        playerView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        container.addSubview(playerView)
        playerView.edges(to: container)
        playerViewPlay()
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ViewController : DismissAnimation {
    func dismissAnimationWillEnd(for animator: Animator) {
        DispatchQueue.main.async {
            self.tableView.setContentOffset(self.originalOffset, animated: false)
        }
    }
    
//    func dismissAnimationDidEnd(for animator: Animator) {
//        DispatchQueue.main.async {
//            self.tableView.setContentOffset(self.originalOffset, animated: false)
//        }
//    }
}
