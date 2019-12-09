//
//  VideoCell.swift
//  PlayerView
//
//  Created by 杨志远 on 2019/11/22.
//  Copyright © 2019 BaQiWL. All rights reserved.
//

import UIKit
//
//protocol CellClick : class {
//    func click(at container: UIView)
//}

class VideoCell: UITableViewCell {
    
    weak var delegate : CellClick?

    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
        // Configure the view for the selected state
    }
    
    @IBAction func click(_ sender: UIButton) {
        delegate?.click(at: containerView, url: "")
    }
    
    
}
