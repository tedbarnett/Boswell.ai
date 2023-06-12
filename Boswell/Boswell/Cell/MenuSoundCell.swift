//
//  MenuSoundCell.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//

import UIKit

class MenuSoundCell: UITableViewCell {

    @IBOutlet weak var switchSound: UISwitch!
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
