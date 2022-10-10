//
//  CustumCell.swift
//  FireStoreBasic
//
//  Created by 近藤米功 on 2022/06/20.
//

import UIKit

class CustumCell: UITableViewCell {

    @IBOutlet var answerLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
