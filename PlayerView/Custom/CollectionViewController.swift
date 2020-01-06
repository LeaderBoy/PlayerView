//
//  CollectionViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/29.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {
    
    lazy var player = PlayerView()

    @IBOutlet weak var collectionView: UICollectionView!
    
    var cell : WaterFallCell?
    
    let waterFallCellIdentifier = String(describing: WaterFallCell.self)
    
    let videos = DouYinDataSource()
    
    var animator : InteractiveDismissAnimator!
    var transition : InteractiveDismissTransition!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupCollectionView()
    }
    
    func setupCollectionView() {
        /// collectionViewLayout
        let layout = WaterFallLayout()
        collectionView.collectionViewLayout = layout
        /// register waterfall cell
        let nib = UINib(nibName: waterFallCellIdentifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: waterFallCellIdentifier)
    }

}

extension CollectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: waterFallCellIdentifier, for: indexPath) as! WaterFallCell
        cell.model = videos.models[indexPath.row]
        return cell
    }
}

extension CollectionViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        /// get cell at indexPath
        let cell = collectionView.cellForItem(at: indexPath) as! WaterFallCell
        self.cell = cell
        /// get model at indexPath
        let model = videos.models[indexPath.row]
        /// create controller
        let playerVC = InteractivePlayerViewController(container : cell.container,imageView: cell.imageView, model: model)
        /// create animator
        let animator = InteractiveDismissAnimator(sourceView: cell.container)
        self.animator = animator
        /// create transition
        let transition = InteractiveDismissTransition(animator: animator)
        self.transition = transition
        /// present
        playerVC.transitioningDelegate = transition
        playerVC.modalPresentationStyle = .overFullScreen
        present(playerVC, animated: true, completion: nil)
    }
}

extension CollectionViewController : PresentAnimation {
    func presentAnimationWillBegin() {
        cell?.present()
    }
}

extension CollectionViewController : DismissAnimation {
    func dismissAnimationDidEnd() {
        cell?.dismiss()
    }
}

