//
//  PopupMenuViewController.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//

import UIKit

protocol PopupMenuViewControllerDelegate: NSObjectProtocol {
    func popupMenuViewControllerDidSelect(menu: String)
}

class PopupMenuViewController: UIViewController {
    @IBOutlet weak var tableViewMenu: UITableView!
    let arrayMenu: [MenuModel] = MenuModel.getMenuList()
    weak var delegate: PopupMenuViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        tableViewMenu.register(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        tableViewMenu.register(UINib(nibName: "MenuSoundCell", bundle: nil), forCellReuseIdentifier: "MenuSoundCell")
        tableViewMenu.delegate = self
        tableViewMenu.dataSource = self
        tableViewMenu.reloadData()
    }
}

extension PopupMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMenu.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = arrayMenu[indexPath.row]
        let menuTitle = menu.menuTitle
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        cell.selectionStyle = .none
        cell.lblTitle.text = menuTitle
        cell.imgIcon.image = UIImage(systemName: menu.menuIcon ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menu = arrayMenu[indexPath.row]
        let menuTitle = menu.menuTitle
        self.dismiss(animated: true)
        self.delegate?.popupMenuViewControllerDidSelect(menu: menuTitle ?? "")
    }
}
