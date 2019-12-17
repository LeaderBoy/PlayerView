//
//  TextCell.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/12/17.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit

class TextCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    
    var model : MovieModel! {
        didSet {
            label.text = model.movieName + model.videoTitle
            tagLabel.text = model.type.reduce("",{$0 + " " + $1})
        }
    }
}
