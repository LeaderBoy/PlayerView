//
//  WaterFallCell.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/29.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit
import Kingfisher

class WaterFallCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    var model : MovieModel! {
        didSet {
            if let url = URL(string: model.coverImg) {
                imageView.kf.setImage(with: url,options: [.transition(.fade(1))])
            }
            titleLabel.text = model.movieName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .red
    }

}
