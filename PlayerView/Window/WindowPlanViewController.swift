//
//  WindowPlanViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/17.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class WindowPlanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource : MovieDataSource!
    
    lazy var player : PlayerView = {
        let player = PlayerView()
        player.plan = .window
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    func setupTableView() {
        dataSource = MovieDataSource(with: self)
        
        let nib = UINib(nibName: dataSource.HomeListCellID, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: dataSource.HomeListCellID)
        let textNib = UINib(nibName: dataSource.TextCellID, bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: dataSource.TextCellID)
        tableView.backgroundColor = .groupTableViewBackground
        tableView.delaysContentTouches = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.dataSource = dataSource
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}

extension WindowPlanViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let i = player.indexPath,i == indexPath {
            player.stop()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        
        var newPlayer : PlayerView?
        if let index = player.indexPath,indexPath == index {
            newPlayer = player
        }else {
           player.stop()
        }
        
        let detail = VideoDetailViewController(playerView: newPlayer)
        detail.model = dataSource.models[indexPath.row]
        navigationController?.pushViewController(detail, animated: true)
    }
    
}

extension WindowPlanViewController : CellClick {
    func click(model: MovieModel, at container: UIView) {
        if let url = URL(string: model.url) {
            player.prepare(url: url, in: container, at: model.indexPath)
        }
    }
}
