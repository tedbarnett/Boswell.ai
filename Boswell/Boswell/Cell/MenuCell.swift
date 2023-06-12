//
//  MenuCell.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var imgIconLeading: NSLayoutConstraint!
    @IBOutlet weak var imgIconWidth: NSLayoutConstraint!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func hideImage() {
        imgIconLeading.constant = 0
        imgIconWidth.constant = 0
    }
}
