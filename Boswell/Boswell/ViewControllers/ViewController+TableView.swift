//
//  ViewController+TableView.swift
//  Boswell
//
//  Created by MyMac on 02/05/23.
//

import UIKit

extension ViewController {
    func setupChatTableView() {
        self.tableViewChat.sectionHeaderTopPadding = 0
        self.tableViewChat.register(UINib(nibName: "UserPromptCell", bundle: nil), forCellReuseIdentifier: "UserPromptCell")
        self.tableViewChat.register(UINib(nibName: "ImageChatCell", bundle: nil), forCellReuseIdentifier: "ImageChatCell")
        self.tableViewChat.register(UINib(nibName: "AIResponseCell", bundle: nil), forCellReuseIdentifier: "AIResponseCell")
        self.tableViewChat.delegate = self
        self.tableViewChat.dataSource = self
    }
    
    func addRow(content: String?, role: AIPromptModel.Role?, isDisplay: Bool = true, isAddToHisoty: Bool = true, image: UIImage? = nil, isError: Bool = false) {
        let model = AIPromptModel()
        model.role = role
        model.isDisplay = isDisplay
        model.isAddToHistory = isAddToHisoty
        model.content = content
        model.image = image
        model.isError = isError
        self.updateRow(model: model)
    }
    
    func updateRow(model: AIPromptModel) {
        model.mode = AppData.shared.config.mode
        if AppData.shared.config.mode == .Boswell {
            self.boswellConversationHistory.append(model)
            self.boswellConversationHistoryDisplay = self.boswellConversationHistory.filter({$0.isDisplay == true})
            self.tableViewChat.reloadData()
            if self.boswellConversationHistory.count > 0 {
                self.btnShare.isEnabled = true
            }
            else {
                self.btnShare.isEnabled = false
            }
        }
        else {
            self.conversationHistory.append(model)
            self.conversationHistoryDisplay = self.conversationHistory.filter({$0.isDisplay == true})
            self.tableViewChat.reloadData()
            if self.conversationHistoryDisplay.count > 0 {
                self.btnShare.isEnabled = true
            }
            else {
                self.btnShare.isEnabled = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom() {
        DispatchQueue.main.async {
            if AppData.shared.config.mode == .Boswell {
                if self.boswellConversationHistoryDisplay.count > 0 {
                    let indexPath = IndexPath(row: self.boswellConversationHistoryDisplay.count - 1, section: 0)
                    self.tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            else {
                if self.conversationHistoryDisplay.count > 0 {
                    let indexPath = IndexPath(row: self.conversationHistoryDisplay.count - 1, section: 0)
                    self.tableViewChat.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if AppData.shared.config.mode == .Boswell {
            return self.boswellConversationHistoryDisplay.count
        }
        else {
            return self.conversationHistoryDisplay.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var prompt: AIPromptModel!
        if AppData.shared.config.mode == .Boswell {
            prompt = self.boswellConversationHistoryDisplay[indexPath.row]
        }
        else {
            prompt = self.conversationHistoryDisplay[indexPath.row]
        }
        if prompt.isDisplay {
            if let image = prompt.image {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageChatCell", for: indexPath) as! ImageChatCell
                cell.selectionStyle = .none
                let oldWidth = image.size.width
                let scaleFactor = oldWidth / (UIScreen.main.bounds.size.width - 40);
                cell.imgAIImage.image = UIImage(cgImage: image.cgImage!, scale: scaleFactor, orientation: .up)
                return cell
            }
            else {
                if prompt.role == .user {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UserPromptCell", for: indexPath) as! UserPromptCell
                    cell.selectionStyle = .none
                    cell.setData(prompt: prompt)
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AIResponseCell", for: indexPath) as! AIResponseCell
                    cell.selectionStyle = .none
                    if indexPath.row > 0 {
                        if AppData.shared.config.mode == .Boswell {
                            let previousPrompt = self.boswellConversationHistoryDisplay[indexPath.row - 1]
                            cell.setData(prompt: prompt, previousPrompt: previousPrompt)
                        }
                        else {
                            let previousPrompt = self.conversationHistoryDisplay[indexPath.row - 1]
                            cell.setData(prompt: prompt, previousPrompt: previousPrompt)
                        }
                    }
                    else {
                        cell.setData(prompt: prompt)
                    }
                    return cell
                }
            }
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserPromptCell", for: indexPath) as! UserPromptCell
            cell.selectionStyle = .none
            cell.lblText.text = ""
            cell.lblText.isHidden = true
            return cell
        }
    }
}
