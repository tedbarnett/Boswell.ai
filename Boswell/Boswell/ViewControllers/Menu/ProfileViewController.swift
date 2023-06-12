//
//  EnterBirthdateViewController.swift
//  Boswell
//
//  Created by MyMac on 24/04/23.
//

import UIKit

protocol ProfileViewControllerDelegate: NSObjectProtocol {
    func profileViewControllerDelegateDidEnter(birthdate: Date, firstname: String, isUpdated: Bool, isParentProfile: Bool, isSilveMode: Bool)
    func profileViewControllerDelegateDidCancel(isParentProfile: Bool)
    func profileViewControllerDidSelectPhotosForParent(birthdate: Date, firstname: String)
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var scrollViewContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var viewContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var txtFirstname: UITextField!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var lblSimplifiesinterfaceTitle: UILabel!
    @IBOutlet weak var lblSilverModeText: UILabel!
    @IBOutlet weak var btnSilverModeCheckBox: UIButton!
    @IBOutlet weak var btnSilverModelTapableButton: UIButton!
    @IBOutlet weak var lblSilverModeInfo: UILabel!
    @IBOutlet weak var lblFirstname: UILabel!
    @IBOutlet weak var lblBirthdate: UILabel!

    weak var delegate: ProfileViewControllerDelegate?
    var selectedDate: Date?
    var firstname: String?
    var isParentProfile: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.registerKeyboardNotification()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unRegisterKeyboardNotification()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateViewHeight()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // Setup the UI of the screen
    func setupUI() {
        self.btnSilverModelTapableButton.titleLabel?.numberOfLines = 2
        self.btnSilverModelTapableButton.titleLabel?.textAlignment = .center
        txtFirstname.delegate = self
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())! // 16 year validation
        if let date = self.selectedDate {
            datePicker.date = date
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: "1960-01-01") ?? Date()
            datePicker.date = date
        }
        self.txtFirstname.text = self.firstname
        
        self.viewContainer.layer.masksToBounds = true
        self.viewContainer.layer.cornerRadius = 10.0
        
        self.btnSave.layer.masksToBounds = true
        self.btnSave.layer.cornerRadius = 8.0

        self.updateViewHeight()
        self.scrollViewContainerHeight.constant = 600
        if self.isParentProfile {
            self.lblFirstname.text = "Parent's first name"
            self.lblBirthdate.text = "Parent's date of birth"
            self.lblTitle.text = "Parent's Profile"
            self.lblInfo.text = "Please enter your parent's name and birthdate below."
            self.lblSilverModeInfo.text = ""
            self.lblSimplifiesinterfaceTitle.isHidden = true
            self.btnSilverModeCheckBox.isHidden = true
            self.lblSilverModeText.isHidden = true
            self.btnSilverModelTapableButton.setTitle("Select family photos for Boswell to ask about", for: .normal)
            self.btnSilverModeCheckBox.isSelected = false
        }
        else {
            self.btnSilverModeCheckBox.isSelected = AppData.shared.config.isSilverMode
            self.lblFirstname.text = "My first name:"
            self.lblBirthdate.text = "My date of birth:"
            if UserDefaultsManager.getParentBirthdate() == nil || UserDefaultsManager.getParentFirstname() == nil {
                self.lblSilverModeInfo.text = ""
                self.lblSimplifiesinterfaceTitle.isHidden = true
                self.btnSilverModeCheckBox.isHidden = true
                self.lblSilverModeText.isHidden = true
            }
            else {
                self.lblSilverModeInfo.text = ""
                self.lblSimplifiesinterfaceTitle.isHidden = false
                self.btnSilverModeCheckBox.isHidden = false
                self.lblSilverModeText.isHidden = false
            }
            self.btnSilverModelTapableButton.setTitle("", for: .normal)
            self.lblTitle.text = "My Profile"
            self.lblInfo.text = "Enter your name and birthdate to help Boswell interview you."
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func updateViewHeight() {
        if UIDevice.current.orientation.isLandscape {
            self.viewContainerHeight.constant = 320
        } else {
            self.viewContainerHeight.constant = 600
        }
    }
    
    func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unRegisterKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        let firstname = self.txtFirstname.text!.isEmpty ? "My friend" : self.txtFirstname.text!
        self.dismiss(animated: true)
        var isUpdate: Bool = false
        if self.firstname != self.txtFirstname.text || self.selectedDate != self.datePicker.date {
            isUpdate = true
        }
        if AppData.shared.config.isSilverMode != self.btnSilverModeCheckBox.isSelected && !self.isParentProfile {
            isUpdate = true
        }
        self.delegate?.profileViewControllerDelegateDidEnter(birthdate: self.datePicker.date, firstname: firstname, isUpdated: isUpdate, isParentProfile: self.isParentProfile, isSilveMode: self.isParentProfile ? false : self.btnSilverModeCheckBox.isSelected)
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.delegate?.profileViewControllerDelegateDidCancel(isParentProfile: self.isParentProfile)
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSilverModeAction(_ sender: Any) {
        if let buttonTitle = self.btnSilverModelTapableButton.title(for: .normal), buttonTitle == "Select family photos for Boswell to ask about" {
            let firstname = self.txtFirstname.text!.isEmpty ? "My friend" : self.txtFirstname.text!
            self.dismiss(animated: true)
            self.delegate?.profileViewControllerDidSelectPhotosForParent(birthdate: self.datePicker.date, firstname: firstname)
        }
        else {
            btnSilverModeCheckBox.isSelected = !btnSilverModeCheckBox.isSelected
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        // In iOS 16.1 and later, the keyboard notification object is the screen the keyboard appears on.
        guard let screen = notification.object as? UIScreen,
              // Get the keyboard’s frame at the end of its animation.
              let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // Use that screen to get the coordinate space to convert from.
        let fromCoordinateSpace = screen.coordinateSpace

        // Get your view's coordinate space.
        let toCoordinateSpace: UICoordinateSpace = view

        // Convert the keyboard's frame from the screen's coordinate space to your view's coordinate space.
        let convertedKeyboardFrameEnd = fromCoordinateSpace.convert(keyboardFrameEnd, to: toCoordinateSpace)
        
        // Get the safe area insets when the keyboard is offscreen.
        var bottomOffset = view.safeAreaInsets.bottom
            
        // Get the intersection between the keyboard's frame and the view's bounds to work with the
        // part of the keyboard that overlaps your view.
        let viewIntersection = view.bounds.intersection(convertedKeyboardFrameEnd)
            
        // Check whether the keyboard intersects your view before adjusting your offset.
        if !viewIntersection.isEmpty {
                
            // Adjust the offset by the difference between the view's height and the height of the
            // intersection rectangle.
            bottomOffset = view.bounds.maxY - viewIntersection.minY
        }

        // Use the new offset to adjust your UI, for example by changing a layout guide, offsetting
        // your view, changing a scroll inset, and so on. This example uses the new offset to update
        // the value of an existing Auto Layout constraint on the view.
        if self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= (bottomOffset / 2)
        }
        //movingBottomConstraint.constant = bottomOffset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtFirstname.resignFirstResponder()
        return true
    }
}
