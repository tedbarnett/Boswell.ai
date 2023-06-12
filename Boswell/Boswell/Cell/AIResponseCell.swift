//
//  AIResponseCell.swift
//  Boswell
//
//  Created by MyMac on 04/05/23.
//

import UIKit

class AIResponseCell: UITableViewCell {

    @IBOutlet weak var lblTextTop: NSLayoutConstraint!
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
    
    func setData(prompt: AIPromptModel, previousPrompt: AIPromptModel? = nil) {
        var content = prompt.content ?? ""
        if let range = content.range(of: "-*---photo-question:") {
            let upperBound = content.index(range.upperBound, offsetBy: 8)
            let modifiedRange = range.lowerBound..<upperBound
            content.removeSubrange(modifiedRange)
            content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if prompt.role == .assistant || prompt.role == .system { // AI Response
            self.lblText.attributedText = Utility.getFormattedAI(response: content)
        }
        else { // Display messsage
            self.lblText.attributedText = Utility.getFormattedDisplay(message: content)
        }
        
        if prompt.mode == .ChatGPT || prompt.mode == .CreateImage {
            if prompt.role != nil {
                self.lblTextBottom.constant = 21
                self.lblTextTop.constant = 0
            }
            else {
                if let tempPrompt = previousPrompt, tempPrompt.role == .assistant, tempPrompt.mode == .Boswell {
                    self.lblTextTop.constant = 21
                    self.lblTextBottom.constant = 21
                }
                else {
                    self.lblTextBottom.constant = 21
                    self.lblTextTop.constant = 0
                }
            }
        }
        else {
            if prompt.role != nil {
                self.lblTextBottom.constant = 2
                self.lblTextTop.constant = 0
            }
            else {
                self.lblTextTop.constant = 0
                self.lblTextBottom.constant = 21
            }
        }
    }
}
