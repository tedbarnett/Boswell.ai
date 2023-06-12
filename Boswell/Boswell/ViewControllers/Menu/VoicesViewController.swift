//
//  VoicesViewController.swift
//  Boswell
//
//  Created by MyMac on 18/05/23.
//

import UIKit

class VoicesViewController: UIViewController {
    @IBOutlet weak var tableViewVoices: UITableView!
    var arrayVoices: [[String: Any]] = {
        guard let plistPath = Bundle.main.path(forResource: "voices", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath),
              let voices = plistDict["voices"] as? [[String: Any]] else {
            return []
        }
        return voices
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        tableViewVoices.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        tableViewVoices.delegate = self
        tableViewVoices.dataSource = self
        tableViewVoices.reloadData()
    }

}

extension VoicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayVoices.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let voice = arrayVoices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.selectionStyle = .none
        let voiceId = voice["voice_id"] as? String ?? ""
        if voiceId == APIManager.shared.elevenLabVoiceId {
            cell.lblTitle.textColor = UIColor.black
            cell.contentView.backgroundColor = UIColor.white
        }
        else {
            cell.lblTitle.textColor = UIColor.white
            cell.contentView.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        }
        cell.lblTitle.text = voice["voice_name"] as? String
        cell.imgIcon.image = nil
        cell.hideImage()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voice = arrayVoices[indexPath.row]
        if let voiceId = voice["voice_id"] as? String {
            APIManager.shared.elevenLabVoiceId = voiceId
        }
        self.dismiss(animated: true)
    }
}
