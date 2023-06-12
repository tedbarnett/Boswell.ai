//
//  AudioListCell.swift
//  Boswell
//
//  Created by MyMac on 24/05/23.
//

import UIKit

class AudioListCell: UITableViewCell {

    @IBOutlet weak var lblFilename: UILabel!
    @IBOutlet weak var viewPlayContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI() {
        self.viewPlayContainer.layer.masksToBounds = true
        self.viewPlayContainer.layer.cornerRadius = self.viewPlayContainer.bounds.size.width / 2
    }
}
