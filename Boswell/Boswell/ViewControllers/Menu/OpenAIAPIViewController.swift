//
//  OpenAIAPIViewController.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//

import UIKit
import SafariServices

protocol OpenAIAPIViewControllerDelegate: NSObjectProtocol {
    func openAIAPIViewControllerDidSave(isGPTCall: Bool)
}

class OpenAIAPIViewController: UIViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTextViewOpenAIKeyContainer: UIView!
    @IBOutlet weak var textViewOpenAIKey: UITextView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnGpt4: UIButton!
    @IBOutlet weak var btnGpt35: UIButton!
    
    weak var delegate: OpenAIAPIViewControllerDelegate?
    var isRequiredGPTCall: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        self.viewContainer.layer.masksToBounds = true
        self.viewContainer.layer.cornerRadius = 10.0
        
        self.viewTextViewOpenAIKeyContainer.layer.masksToBounds = true
        self.viewTextViewOpenAIKeyContainer.layer.cornerRadius = 8.0
        self.viewTextViewOpenAIKeyContainer.layer.borderWidth = 1.0
        self.viewTextViewOpenAIKeyContainer.layer.borderColor = UIColor.lightGray.cgColor
        
        self.btnSave.layer.masksToBounds = true
        self.btnSave.layer.cornerRadius = 8.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func setData() {
        self.textViewOpenAIKey.text = APIManager.shared.openAI_APIKey
        if AppData.shared.config.apiModel == .ChatGPT_4 {
            gpt4ButtonPress()
        }
        else {
            gpt35ButtonPress()
        }
    }
    
    func gpt4ButtonPress() {
        self.btnGpt4.isSelected = true
        self.btnGpt35.isSelected = false
    }
    
    func gpt35ButtonPress() {
        self.btnGpt4.isSelected = false
        self.btnGpt35.isSelected = true
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func btnGpt4Action(_ sender: Any) {
        self.gpt4ButtonPress()
    }
    
    @IBAction func btnGpt35Action(_ sender: Any) {
        self.gpt35ButtonPress()
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        if self.textViewOpenAIKey.text!.isEmpty {
            Utility.showAlert(title: "", message: "OpenAI Key is required.", vc: self)
        }
        else {
            UserDefaultsManager.saveOpenAI(APIKey: self.textViewOpenAIKey.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            AppData.shared.config.saveApi(model: self.btnGpt4.isSelected ? .ChatGPT_4 : .ChatGPT_3_5)
            self.dismiss(animated: true)
            self.delegate?.openAIAPIViewControllerDidSave(isGPTCall: isRequiredGPTCall)
        }
    }
    
    @IBAction func btnBoswellGithubAction(_ sender: Any) {
        let vc = SFSafariViewController(url: URL(string: "https://github.com/tedbarnett/Boswell")!)
        self.present(vc, animated: true)
    }
}
