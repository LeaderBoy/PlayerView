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

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    
    @IBOutlet weak var staticStackView: UIStackView!
    var model : DouYinModel! {
        didSet {
            if let url = URL(string: model.video.cover.url_list[0]) {
                imageView.kf.setImage(with: url,options: [.transition(.fade(1))])
            }
            titleLabel.text = model.desc
            numberLabel.text = "播放\(model.statistics.digg_count)次"
        }
    }
    
    func present() {
        staticStackView.isHidden = true
    }
   
    func dismiss() {
        staticStackView.isHidden = false
    }
}
