//
//  VideoListCell.swift
//  Boswell
//
//  Created by MyMac on 12/06/23.
//

import UIKit

class VideoListCell: UITableViewCell {

    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgThumb: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
