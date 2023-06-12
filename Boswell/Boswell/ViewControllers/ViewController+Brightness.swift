//
//  ViewController+Brightness.swift
//  Boswell
//
//  Created by MyMac on 01/05/23.
//

import UIKit

extension ViewController {
//    func showBrightnessControl() {
//        if self.viewBrightnessControl == nil {
//            self.viewBrightnessControl = BrightnessControlView.fromNib()
//            self.viewBrightnessControl?.alpha = 0
//            self.viewBrightnessControl?.translatesAutoresizingMaskIntoConstraints = false
//            self.view.addSubview(self.viewBrightnessControl!)
//            self.viewBrightnessControl?.leadingAnchor.constraint(equalTo: self.btnBrightness.leadingAnchor, constant: 0).isActive = true
//            self.viewBrightnessControl?.trailingAnchor.constraint(equalTo: self.btnBrightness.trailingAnchor, constant: 0).isActive = true
//            self.viewBrightnessControl?.bottomAnchor.constraint(equalTo: self.btnBrightness.topAnchor, constant: -15).isActive = true
//            self.viewBrightnessControlHeight = self.viewBrightnessControl?.heightAnchor.constraint(equalToConstant: 0)
//            self.viewBrightnessControlHeight?.isActive = true
//            //self.viewBrightnessControl?.layoutIfNeeded()
//            self.viewBrightnessControl?.delegate = self
//            self.view.layoutIfNeeded()
//            self.viewBrightnessControlHeight?.constant = 250
//            UIView.animate(withDuration: 0.2) {
//                self.viewBrightnessControl?.alpha = 1.0
//                self.view.layoutIfNeeded()
//            } completion: { finished in
//                self.viewBrightnessControl?.setupUI(brightness: self.backgroundBrightness)
//            }
//        }
//    }
//
//    func dismissBrightnessControl() {
//        if self.viewBrightnessControl != nil && self.viewBrightnessControlHeight != nil {
//            self.viewBrightnessControlHeight?.constant = 0
//            UIView.animate(withDuration: 0.2) {
//                self.viewBrightnessControl?.alpha = 0.0
//                self.view.layoutIfNeeded()
//            } completion: { finished in
//                self.viewBrightnessControl?.removeFromSuperview()
//                self.viewBrightnessControl = nil
//                self.btnBrightness.isSelected = false
//            }
//        }
//    }
//
//    func showBrightnessOption() {
//        UIView.animate(withDuration: 0.3) {
//            self.btnBrightness.alpha = 1.0
//        }
//    }
//
//    func hideBrightnessOption() {
//        UIView.animate(withDuration: 0.2) {
//            self.btnBrightness.alpha = 0.0
//        } completion: { finished in
//            self.dismissBrightnessControl()
//        }
//    }
}

extension ViewController: BrightnessControlViewDelegate {
    func brightnessControlViewDidChange(brightness: Float) {
        //self.backgroundBrightness = brightness
        //self.viewImgBackgroundOpacity.alpha = CGFloat(brightness)
    }
}
