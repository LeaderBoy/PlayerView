//
//  HomeListCell.swift
//  PlayerView
//
//  Created by 杨 on 2019/12/9.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit
import Kingfisher


protocol CellClick : class {
    func click(model : MovieModel,at container: UIView)
}

class HomeListCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    weak var delegate : CellClick?
    
    var model : MovieModel! {
        didSet {
            if let url = URL(string: model.coverImg) {
                coverImageView.kf.setImage(with: url,options: [.transition(.fade(1))])
            }
            desLabel.text = model.movieName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 5
    }
        
    @IBAction func play(_ sender: UIButton) {
        delegate?.click(model: model, at: containerView)
    }
}
