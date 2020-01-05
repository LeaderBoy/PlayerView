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

    var player : PlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let player = self.player else { return  }
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
        if let player = self.player {
            return player.supportedInterfaceOrientations
        }
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        if let player = self.player {
            return player.shouldAutorotate
        }
        return true
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let player = self.player else { return  }
        if newCollection.verticalSizeClass == .compact {
            player.updateWillChange(tableView)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard let player = self.player else { return  }
        if let pre = previousTraitCollection,pre.verticalSizeClass == .compact {
            player.updateDidChange(tableView)
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
        guard let player = self.player else { return  }
        if player.indexPath == indexPath {
            player.stop()
        }
    }
}

extension PresentPlanViewController : CellClick {
    func click(model: MovieModel, at container: UIView) {
        if let url = URL(string: model.url) {
            if player == nil {
                let player = PlayerView()
                player.plan = .present
                self.player = player
            }
            player!.prepare(url: url, in: container, at: model.indexPath)
        }
    }
}



