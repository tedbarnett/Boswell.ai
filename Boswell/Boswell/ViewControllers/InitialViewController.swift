//
//  InitialViewController.swift
//  Boswell
//
//  Created by MyMac on 29/05/23.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var lblPreparing: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaultsManager.getAppLaunchFlag() {
            lblPreparing.isHidden = false
        }
        else {
            lblPreparing.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigation") as! UINavigationController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    

}
