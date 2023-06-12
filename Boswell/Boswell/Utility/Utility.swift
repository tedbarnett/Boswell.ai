//
//  Utility.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//

import UIKit

class Utility: NSObject {
    static func showAlert(title: String?, message: String?, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        vc.present(alert, animated: true)
    }
    
    static func showLoader(status: String) {
        if let window = UIApplication.shared.keyWindow {
            let contentView = UIView(frame: CGRect.zero)
            contentView.backgroundColor = UIColor.clear
            contentView.tag = 101
            contentView.alpha = 0.0
            contentView.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(contentView)
            contentView.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 0).isActive = true
            contentView.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: 0).isActive = true
            contentView.topAnchor.constraint(equalTo: window.topAnchor, constant: 0).isActive = true
            contentView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0).isActive = true
            
            let loadingOverlayView = UIView(frame: CGRect.zero)
            loadingOverlayView.alpha = 0.0
            loadingOverlayView.backgroundColor = UIColor(red: 39.0/255.0, green: 41.0/255.0, blue: 41.0/255.0, alpha: 1.0)
            loadingOverlayView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(loadingOverlayView)
            
            loadingOverlayView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
            loadingOverlayView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
            loadingOverlayView.widthAnchor.constraint(equalToConstant: 200.0).isActive = true
            loadingOverlayView.heightAnchor.constraint(equalToConstant: 110.0).isActive = true
            
            loadingOverlayView.layer.masksToBounds = true
            loadingOverlayView.layer.cornerRadius = 10.0
            
            let activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.alpha = 0.0
            loadingOverlayView.addSubview(activityIndicator)
            activityIndicator.hidesWhenStopped = true
            activityIndicator.startAnimating()
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            
            activityIndicator.topAnchor.constraint(equalTo: loadingOverlayView.topAnchor, constant: 20).isActive = true
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlayView.centerXAnchor, constant: 0).isActive = true
            
            let lblStatus = UILabel(frame: CGRect.zero)
            lblStatus.alpha = 0.0
            lblStatus.tag = 102
            lblStatus.textColor = UIColor.white
            lblStatus.text = status
            lblStatus.font = UIFont(name: "Lato-Bold", size: 20.0)
            lblStatus.textAlignment = .center
            loadingOverlayView.addSubview(lblStatus)
            lblStatus.translatesAutoresizingMaskIntoConstraints = false
            
            lblStatus.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10).isActive = true
            lblStatus.leadingAnchor.constraint(equalTo: loadingOverlayView.leadingAnchor, constant: -10).isActive = true
            lblStatus.trailingAnchor.constraint(equalTo: loadingOverlayView.trailingAnchor, constant: 10).isActive = true
            lblStatus.bottomAnchor.constraint(equalTo: loadingOverlayView.bottomAnchor, constant: -10).isActive = true
            
            UIView.animate(withDuration: 0.3) {
                contentView.alpha = 1.0
                loadingOverlayView.alpha = 1.0
                activityIndicator.alpha = 1.0
                lblStatus.alpha = 1.0
            }
        }
    }
    
    static func updateLoader(status: String) {
        if let window = UIApplication.shared.keyWindow, let loaderView = window.viewWithTag(101), let lblStatus = loaderView.viewWithTag(102) as? UILabel {
            lblStatus.text = status
        }
    }
    
    static func hideLoader() {
        if let window = UIApplication.shared.keyWindow, let loaderView = window.viewWithTag(101) {
            UIView.animate(withDuration: 0.3) {
                loaderView.alpha = 0.0
            } completion: { finished in
                loaderView.removeFromSuperview()
            }
        }
    }

    static func getDirectoryURL(name: String) -> URL? {
        let documentDirectory = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let dirPath = documentDirectory.appendingPathComponent(name)
        do {
            try FileManager.default.createDirectory(atPath: dirPath!.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Unable to create directory \(error.debugDescription)")
            return nil
        }
        return dirPath
    }
    
    static func getFormattedUser(input: String) -> NSAttributedString {
        let userPromptFontSize = CGFloat(UserDefaultsManager.getUserPromptFontSize())
        let userPromptFontWeight = UserDefaultsManager.getUserPromptFontWeight()
        let userPromptFontColor = UserDefaultsManager.getUserPromptFontColor()
        let userPromptFont = userPromptFontWeight == "normal" ?  UIFont(name: "Lato-Regular", size: userPromptFontSize)! :  UIFont(name: "Lato-Bold", size: userPromptFontSize)!
        
        // Append the formatted user input and AI's response to the conversation history
        let attributesUserText: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(hex: userPromptFontColor), .font: userPromptFont] // gray color
        let formattedUserInput = NSAttributedString(string: input, attributes: attributesUserText)
        return formattedUserInput
    }
    
    static func getFormattedAI(response: String) -> NSAttributedString {
        let aiResponseFontSize = CGFloat(UserDefaultsManager.getAIResponseFontSize())
        let aiResponseFontWeight = UserDefaultsManager.getAIResponseFontWeight()
        let aiResponseFontColor = UserDefaultsManager.getAIResponseFontColor()
        
        let aiResponseFont = aiResponseFontWeight == "normal" ?  UIFont(name: "Lato-Regular", size: aiResponseFontSize)! :  UIFont(name: "Lato-Bold", size: aiResponseFontSize)!
        
        let attributesAIText: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(hex: aiResponseFontColor), .font: aiResponseFont] // greenish color
        let formattedAIResponse = NSAttributedString(string: response, attributes: attributesAIText)
        return formattedAIResponse
    }
    
    static func getFormattedDisplay(message: String) -> NSAttributedString {
        let fontColor = "#E97451"
        let font = UIFont(name: "Lato-Regular", size: 18.0)!
        // Append the formatted user input and AI's response to the conversation history
        let attributesText: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(hex: fontColor), .font: font] // gray color
        let formattedInput = NSAttributedString(string: message, attributes: attributesText)
        return formattedInput
    }
    
    static func getInterviewFilename() -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "yyyy-MM-dd hh-mma"
        let strDate = formatter3.string(from: Date())
        var username: String = "User"
        if let name = UserDefaultsManager.getFirstname(), name != "" {
            username = name
        }
        let filename = "\(username) \(strDate.lowercased()) - Boswell Interview Audio.m4a"
        return filename
    }
    
}
