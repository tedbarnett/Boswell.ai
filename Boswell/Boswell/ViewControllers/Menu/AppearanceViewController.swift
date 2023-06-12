//
//  ApiKeyPopupViewController.swift
//  Boswell
//
//  Created by MyMac on 17/04/23.
//

import UIKit

class AppearanceViewController: UIViewController {
    
    @IBOutlet weak var lblUserFontSize: UILabel!
    @IBOutlet weak var btnUserFontSize: UIButton!
    @IBOutlet weak var lblUserFontWeight: UILabel!
    @IBOutlet weak var btnUserFontWeight: UIButton!
    
    @IBOutlet weak var lblAIFontSize: UILabel!
    @IBOutlet weak var btnAIFontSize: UIButton!
    @IBOutlet weak var lblAIFontWeight: UILabel!
    @IBOutlet weak var btnAIFontWeight: UIButton!
    
    @IBOutlet weak var btnUserColor: UIButton!
    @IBOutlet weak var btnAIColor: UIButton!
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var lblSampleUserPrompt: UILabel!
    @IBOutlet weak var lblSampleAIResponse: UILabel!
    
    let dropdownUserFontSize = DropDown()
    let dropdownUserFontWeight = DropDown()
    let dropdownAIFontSize = DropDown()
    let dropdownAIFontWeight = DropDown()
    let arrayFontSize: [String] = ["8", "12", "14", "16", "18", "20", "22", "24", "26", "28"]
    let arrayFontWeight: [String] = ["normal", "bold"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setData()
        // Do any additional setup after loading the view.
    }
    
    // Setup the UI of the screen
    func setupUI() {
        self.viewContainer.layer.masksToBounds = true
        self.viewContainer.layer.cornerRadius = 10.0
        
        self.btnSave.layer.masksToBounds = true
        self.btnSave.layer.cornerRadius = 8.0
        
        self.btnAIColor.layer.masksToBounds = true
        self.btnAIColor.layer.cornerRadius = self.btnAIColor.bounds.size.width / 2
        
        self.btnUserColor.layer.masksToBounds = true
        self.btnUserColor.layer.cornerRadius = self.btnAIColor.bounds.size.width / 2
        
        // The view to which the drop down will appear on
        dropdownAIFontSize.anchorView = self.btnAIFontSize // UIView or UIBarButtonItem
        dropdownAIFontSize.direction = .bottom
        dropdownAIFontSize.bottomOffset = CGPoint(x: 0, y: self.btnAIFontSize.bounds.size.height)
        dropdownAIFontSize.backgroundColor = UIColor(hex: "#313136")
        dropdownAIFontSize.selectedTextColor = UIColor.white
        dropdownAIFontSize.selectionBackgroundColor = UIColor.systemGray3
        dropdownAIFontSize.textColor = UIColor.white
        dropdownAIFontSize.cellHeight = 32.0
        dropdownAIFontSize.textFont = UIFont(name: "Lato-Regular", size: 16.0)!
        // The list of items to display. Can be changed dynamically
        dropdownAIFontSize.dataSource = arrayFontSize
        // Action triggered on selection
        dropdownAIFontSize.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblAIFontSize.text = item
            self.updateSamplePromtLabel()
        }
        // Will set a custom width instead of the anchor view width
        dropdownAIFontSize.width = 84
        
        // The view to which the drop down will appear on
        dropdownUserFontSize.anchorView = self.btnUserFontSize // UIView or UIBarButtonItem
        dropdownUserFontSize.direction = .bottom
        dropdownUserFontSize.bottomOffset = CGPoint(x: 0, y: self.btnUserFontSize.bounds.size.height)
        dropdownUserFontSize.backgroundColor = UIColor(hex: "#313136")
        dropdownUserFontSize.selectedTextColor = UIColor.white
        dropdownUserFontSize.selectionBackgroundColor = UIColor.systemGray3
        dropdownUserFontSize.textColor = UIColor.white
        dropdownUserFontSize.cellHeight = 32.0
        dropdownUserFontSize.textFont = UIFont(name: "Lato-Regular", size: 16.0)!
        // The list of items to display. Can be changed dynamically
        dropdownUserFontSize.dataSource = arrayFontSize
        // Action triggered on selection
        dropdownUserFontSize.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblUserFontSize.text = item
            self.updateSamplePromtLabel()
        }
        // Will set a custom width instead of the anchor view width
        dropdownUserFontSize.width = 84
        
        // The view to which the drop down will appear on
        dropdownAIFontWeight.anchorView = self.btnAIFontWeight // UIView or UIBarButtonItem
        dropdownAIFontWeight.direction = .bottom
        dropdownAIFontWeight.bottomOffset = CGPoint(x: 0, y: self.btnAIFontWeight.bounds.size.height)
        dropdownAIFontWeight.backgroundColor = UIColor(hex: "#313136")
        dropdownAIFontWeight.selectedTextColor = UIColor.white
        dropdownAIFontWeight.selectionBackgroundColor = UIColor.systemGray3
        dropdownAIFontWeight.textColor = UIColor.white
        dropdownAIFontWeight.cellHeight = 32.0
        dropdownAIFontWeight.textFont = UIFont(name: "Lato-Regular", size: 16.0)!
        // The list of items to display. Can be changed dynamically
        dropdownAIFontWeight.dataSource = arrayFontWeight
        // Action triggered on selection
        dropdownAIFontWeight.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblAIFontWeight.text = item
            self.updateSamplePromtLabel()
        }
        // Will set a custom width instead of the anchor view width
        dropdownAIFontWeight.width = 104
        
        // The view to which the drop down will appear on
        dropdownUserFontWeight.anchorView = self.btnUserFontWeight // UIView or UIBarButtonItem
        dropdownUserFontWeight.direction = .bottom
        dropdownUserFontWeight.bottomOffset = CGPoint(x: 0, y: self.btnUserFontWeight.bounds.size.height)
        dropdownUserFontWeight.backgroundColor = UIColor(hex: "#313136")
        dropdownUserFontWeight.selectedTextColor = UIColor.white
        dropdownUserFontWeight.selectionBackgroundColor = UIColor.systemGray3
        dropdownUserFontWeight.textColor = UIColor.white
        dropdownUserFontWeight.cellHeight = 32.0
        dropdownUserFontWeight.textFont = UIFont(name: "Lato-Regular", size: 16.0)!
        // The list of items to display. Can be changed dynamically
        dropdownUserFontWeight.dataSource = arrayFontWeight
        // Action triggered on selection
        dropdownUserFontWeight.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.lblUserFontWeight.text = item
            self.updateSamplePromtLabel()
        }
        // Will set a custom width instead of the anchor view width
        dropdownUserFontWeight.width = 104
    }
    
    // Set data from UserDefaults
    func setData() {
        let userPromptFontSize = Int(UserDefaultsManager.getUserPromptFontSize())
        let aiResponseFontSize = Int(UserDefaultsManager.getAIResponseFontSize())
        self.lblUserFontSize.text = "\(userPromptFontSize)"
        self.lblAIFontSize.text = "\(aiResponseFontSize)"
        
        if let userIndex = self.arrayFontSize.firstIndex(where: {$0 == "\(userPromptFontSize)"}) {
            dropdownUserFontSize.selectRow(userIndex)
        }
        
        if let aiIndex = self.arrayFontSize.firstIndex(where: {$0 == "\(aiResponseFontSize)"}) {
            dropdownAIFontSize.selectRow(aiIndex)
        }
        
        let userFontWeight = UserDefaultsManager.getUserPromptFontWeight()
        self.lblUserFontWeight.text = userFontWeight
        
        if let userWeightIndex = self.arrayFontWeight.firstIndex(where: {$0.lowercased() == userFontWeight.lowercased()}) {
            dropdownUserFontWeight.selectRow(userWeightIndex)
        }
        
        let aiFontWeight = UserDefaultsManager.getAIResponseFontWeight()
        self.lblAIFontWeight.text = aiFontWeight
        
        if let aiWeightIndex = self.arrayFontWeight.firstIndex(where: {$0.lowercased() == aiFontWeight.lowercased()}) {
            dropdownAIFontWeight.selectRow(aiWeightIndex)
        }
        
        let userPromptFontColor = UIColor(hex: UserDefaultsManager.getUserPromptFontColor())
        let aiResponseFontColor = UIColor(hex: UserDefaultsManager.getAIResponseFontColor())
        self.btnUserColor.backgroundColor = userPromptFontColor
        self.btnAIColor.backgroundColor = aiResponseFontColor
        self.updateSamplePromtLabel()
    }
    
    // Update sample promt label
    func updateSamplePromtLabel() {
        let userFontWeight = self.lblUserFontWeight.text!
        let aiFontWeight = self.lblAIFontWeight.text!
        
        let userFontSize = CGFloat(Float(self.lblUserFontSize.text!) ?? DeafultFontAppearance.UserPrompts.FontSize)
        let aiFontSize = CGFloat(Float(self.lblAIFontSize.text!) ?? DeafultFontAppearance.AIResponse.FontSize)
        
        let userFontColor = self.btnUserColor.backgroundColor!
        let aiFontColor = self.btnAIColor.backgroundColor!
        
        let userPromptFont = userFontWeight == "normal" ?  UIFont(name: "Lato-Regular", size: userFontSize)! :  UIFont(name: "Lato-Bold", size: userFontSize)!

        let aiResponseFont = aiFontWeight == "normal" ?  UIFont(name: "Lato-Regular", size: aiFontSize)! :  UIFont(name: "Lato-Bold", size: aiFontSize)!
        
        self.lblSampleUserPrompt.font = userPromptFont
        self.lblSampleAIResponse.font = aiResponseFont
        
        self.lblSampleUserPrompt.textColor = userFontColor
        self.lblSampleAIResponse.textColor = aiFontColor
    }

    @IBAction func btnUserFontSizeAction(_ sender: Any) {
        dropdownUserFontSize.show()
    }
    
    @IBAction func btnUserFontWeightAction(_ sender: Any) {
        dropdownUserFontWeight.show()
    }
    
    @IBAction func btnAIResponseFontSizeAction(_ sender: Any) {
        dropdownAIFontSize.show()
    }
    
    @IBAction func btnAIFontWeightAction(_ sender: Any) {
        dropdownAIFontWeight.show()
    }
    
    
    @IBAction func btnUserColorAction(_ sender: Any) {
        // Initializing Color Picker
        let picker = UIColorPickerViewController()
        picker.view.tag = 101
        // Setting the Initial Color of the Picker
        picker.selectedColor = self.btnUserColor.backgroundColor!
        // Setting Delegate
        picker.delegate = self
        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnAIColorAction(_ sender: Any) {
        // Initializing Color Picker
        let picker = UIColorPickerViewController()
        picker.view.tag = 102
        // Setting the Initial Color of the Picker
        picker.selectedColor = self.btnAIColor.backgroundColor!
        // Setting Delegate
        picker.delegate = self
        // Presenting the Color Picker
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        if let userFontSize = Float(self.lblUserFontSize.text!) {
            UserDefaultsManager.saveUserPromptFont(size: userFontSize)
        }
        UserDefaultsManager.saveUserPromptFont(weight: self.lblUserFontWeight.text!)
        let userFontColor = self.btnUserColor.backgroundColor?.hexStringFromColor() ?? "#aaaaaa"
        UserDefaultsManager.saveUserPromptFont(color: userFontColor)
        
        if let aiFontSize = Float(self.lblAIFontSize.text!) {
            UserDefaultsManager.saveAIResponseFont(size: aiFontSize)
        }
        UserDefaultsManager.saveAIResponseFont(weight: self.lblAIFontWeight.text!)
        let aiFontColor = self.btnAIColor.backgroundColor?.hexStringFromColor() ?? "#aaaaaa"
        UserDefaultsManager.saveAIResponseFont(color: aiFontColor)
        self.dismiss(animated: true)
    }
}

extension AppearanceViewController: UIColorPickerViewControllerDelegate {
    //  Called once you have finished picking the color.
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if viewController.view.tag == 101 {
            self.btnUserColor.backgroundColor = viewController.selectedColor
        }
        else {
            self.btnAIColor.backgroundColor = viewController.selectedColor
        }
        updateSamplePromtLabel()
    }
    
    //  Called on every color selection done in the picker.
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if viewController.view.tag == 101 {
            self.btnUserColor.backgroundColor = viewController.selectedColor
        }
        else {
            self.btnAIColor.backgroundColor = viewController.selectedColor
        }
        updateSamplePromtLabel()
    }
}
