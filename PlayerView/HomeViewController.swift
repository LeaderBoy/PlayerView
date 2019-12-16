//
//  HomeViewController.swift
//  PlayerView
//
//  Created by 杨 on 2019/12/9.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

struct MovieModel : Decodable {
    let movieName : String
    let coverImg : String
    let url : String
    let hightUrl : String
    let videoTitle : String
    let videoLength : Int
}


class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let HomeListCellID = "HomeListCell"
    
    var dataSource : [MovieModel] = []
    var playerView : PlayerView?
    
    var orientation : UIInterfaceOrientationMask = .portrait
    var shouldRotate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchMovieModel()
    }
    
//    override func viewSafeAreaInsetsDidChange() {
//        UIView.animate(withDuration: playerAnimationTime) {
//            self.view.layoutIfNeeded()
//        }
//    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if newCollection.verticalSizeClass == .compact {
            playerView?.updateWillChangeTableView(tableView)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let pre = previousTraitCollection,pre.verticalSizeClass == .compact {
            playerView?.updateDidChangeTableView(tableView)
        }
    }
    
    func setupTableView() {
        let nib = UINib(nibName: "HomeListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: HomeListCellID)
        tableView.backgroundColor = .groupTableViewBackground
        tableView.delaysContentTouches = false
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
    
    /// fetch models from movie.json file
    func fetchMovieModel() {
        let jsonPath = Bundle.main.path(forResource: "movie", ofType: "json")!
        let jsonURL = URL(fileURLWithPath: jsonPath)
        
        let data = try! Data(contentsOf: jsonURL)
        let models = try! JSONDecoder().decode([MovieModel].self, from: data)
        dataSource = models
        tableView.reloadData()
    }
    
}

extension HomeViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeListCellID) as! HomeListCell
        cell.model = dataSource[indexPath.row]
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

extension HomeViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var newPlayer : PlayerView?
        if let player = playerView {
            if let index = player.indexPath,indexPath == index {
                newPlayer = player
            }else {
               player.stop()
            }
        }
        let detail = VideoDetailViewController(playerView: newPlayer)
        detail.model = dataSource[indexPath.row]
        navigationController?.pushViewController(detail, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let player = playerView,let i = player.indexPath,i == indexPath {
//            player.stop()
//        }
    }
    
}
extension HomeViewController : CellClick {
    func click(at indexPath: IndexPath, container: UIView) {
        if playerView == nil {
            playerView = PlayerView()
            playerView!.plan = .present
        }
        
        if let url = URL(string: dataSource[indexPath.row].url) {
            playerView!.prepare(url: url, in: container, at: indexPath)
        }
    }
}
