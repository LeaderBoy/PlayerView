//
//  PresentPlanViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/17.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class PresentPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource : MovieDataSource!
    
    var cellHeights : [String:NSNumber] = [:]
    
    typealias ShouldRecord = (CGFloat) -> Bool
    
    let verticalWidth = UIScreen.main.bounds.width
    
    lazy var shouldRecord : ShouldRecord = { number in
        if number == self.verticalWidth {
            return true
        }
        return false
    }

    lazy var player : PlayerView = {
        let player = PlayerView()
        player.plan = .present
        return player
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if player.indexPath != nil {
            player.paused()
        }
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
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        if newCollection.verticalSizeClass == .compact {
            player.updateWillChangeTableView(tableView)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if let pre = previousTraitCollection,pre.verticalSizeClass == .compact {
            player.updateDidChangeTableView(tableView)
        }
    }

}

extension PresentPlanViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let key = "\(indexPath.row)"
        if let number = cellHeights[key] {
            return CGFloat(number.floatValue)
        }else {
            if #available(iOS 11.0, *) {
                return UITableView.automaticDimension
            } else {
                /// prefered max cell height
                return 250
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let width = cell.frame.width
        let height = cell.frame.height
        if shouldRecord(width) {
            let h = Double(height)
            let key = "\(indexPath.row)"
            cellHeights[key] = NSNumber(value: h)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if player.indexPath == indexPath {
            player.stop()
        }
    }
}

extension PresentPlanViewController : CellClick {
    func click(model: MovieModel, at container: UIView) {
        if let url = URL(string: model.url) {
            player.prepare(url: url, in: container, at: model.indexPath)
        }
    }
}



