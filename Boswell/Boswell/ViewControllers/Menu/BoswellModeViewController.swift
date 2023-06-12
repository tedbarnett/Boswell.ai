//
//  BoswellViewController.swift
//  Boswell
//
//  Created by MyMac on 25/04/23.
//

import UIKit
protocol BoswellModeViewControllerDelegate: NSObjectProtocol {
    func boswellModeViewControllerDidSaveSuccessfully(isUpdateMode: Bool, previousMode: BoswellModeModel.BoswellMode)
}

class BoswellModeViewController: UIViewController {

    @IBOutlet weak var tableViewMode: UITableView!
    weak var delegate: BoswellModeViewControllerDelegate?
    var modes: [BoswellModeModel.BoswellMode] = [.Boswell, .ChatGPT, .CreateImage]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        tableViewMode.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        tableViewMode.delegate = self
        tableViewMode.dataSource = self
    }
}

extension BoswellModeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.selectionStyle = .none
        let mode = self.modes[indexPath.row]
        var cellTitle: String = ""
        if mode == .CreateImage {
            cellTitle = "Create Image"
        }
        else if mode == .ChatGPT {
            cellTitle = "ChatGPT"
        }
        else {
            cellTitle = "Boswell"
        }
        cell.lblTitle.text = cellTitle
        if AppData.shared.config.mode == mode {
            cell.lblTitle.textColor = UIColor.black
            cell.contentView.backgroundColor = UIColor.white
        }
        else {
            cell.lblTitle.textColor = UIColor.white
            cell.contentView.backgroundColor = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 30.0/255.0, alpha: 1.0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let previousMode = AppData.shared.config.mode
        AppData.shared.config.save(mode: self.modes[indexPath.row])
        self.dismiss(animated: true)
        self.delegate?.boswellModeViewControllerDidSaveSuccessfully(isUpdateMode: AppData.shared.config.mode != previousMode, previousMode: previousMode)
    }
}
