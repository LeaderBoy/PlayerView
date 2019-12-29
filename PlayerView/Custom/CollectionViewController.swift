//
//  CollectionViewController.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/29.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let waterFallCellIdentifier = String(describing: WaterFallCell.self)
    
    let movies = MovieDataSource()

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
        return movies.models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: waterFallCellIdentifier, for: indexPath) as! WaterFallCell
        
        cell.model = movies.models[indexPath.row]
        
        return cell
    }
}
