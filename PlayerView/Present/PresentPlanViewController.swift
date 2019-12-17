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

    lazy var player : PlayerView = {
        let player = PlayerView()
        player.plan = .present
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
                /// prefered max cell height
                return 250
            } else {
                return UITableView.automaticDimension
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.traitCollection.verticalSizeClass == .regular {
            let h = Double(cell.frame.size.height)
            let key = "\(indexPath.row)"
            cellHeights[key] = NSNumber(value: h)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// when present excute
        /// didEndDisplaying will be called because of tableView reloadData
        /// to prevent landscaping player beening removed
        if player.modeState == .landscape {
            return
        }
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



