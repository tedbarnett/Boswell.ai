//
//  ChatCell.swift
//  Boswell
//
//  Created by MyMac on 02/05/23.
//

import UIKit

class UserPromptCell: UITableViewCell {
    @IBOutlet weak var lblTextBottom: NSLayoutConstraint!
    @IBOutlet weak var lblText: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(prompt: AIPromptModel) {
        self.lblText.attributedText = Utility.getFormattedUser(input: (prompt.content ?? ""))
        if prompt.mode == .ChatGPT || prompt.mode == .CreateImage {
            self.lblTextBottom.constant = 0
        }
        else {
            self.lblTextBottom.constant = 21
        }
    }
    
}
