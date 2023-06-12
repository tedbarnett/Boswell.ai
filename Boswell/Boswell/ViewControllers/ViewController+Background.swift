//
//  ViewController+Background.swift
//  Boswell
//
//  Created by MyMac on 27/04/23.
//

import UIKit

extension ViewController {
    func getBackgroundImage(isParentPhoto: Bool) -> UIImage? {
        let urls = BoswellInterviewHelper.getBackgroundImageURLs(isParentPhoto: isParentPhoto)
        if urls.count > 0 {
//            let randomIndex = Int.random(in: 0..<urls.count)
//            let imageURL = urls[randomIndex]
//            do {
//                let data = try Data(contentsOf: imageURL)
//                return UIImage(data: data)
//            }
//            catch let error {
//                print(error)
//            }
            
            var shownImagesName = UserDefaultsManager.getShownImagesName(isParentPhoto: isParentPhoto)
            var newURLs = urls.filter { url in
                if let _ = shownImagesName.firstIndex(where: {$0 == url.lastPathComponent}) {
                    return false
                }
                else {
                    return true
                }
            }
            if newURLs.count == 0 {
                newURLs = urls
            }
            let randomIndex = Int.random(in: 0..<newURLs.count)
            let imageURL = newURLs[randomIndex]
            do {
                let data = try Data(contentsOf: imageURL)

                if let _ = shownImagesName.firstIndex(where: {$0 == imageURL.lastPathComponent}) {

                }
                else {
                    shownImagesName.append(imageURL.lastPathComponent)
                    UserDefaultsManager.saveShownImages(name: shownImagesName, isParentPhoto: isParentPhoto)
                }
                return UIImage(data: data)
            }
            catch let error {
                print(error)
            }
        }
        return nil
    }
    
    func setBackgroundImage(image: UIImage? = nil) {
        if AppData.shared.config.mode == .Boswell && image != nil {
            if !BoswellInterviewHelper.isUnusedPhotosAvailable(isParentPhoto: AppData.shared.config.isSilverMode) {
                self.addRow(content: boswellInterviewHelper.stopPhotoQuestions, role: .user, isDisplay: false)
            }
        }
        if image != nil {
            self.imgBackground.isHidden = false
            self.imgBackground.alpha = 0.3
            UIView.transition(with: self.imgBackground,
                              duration: 3.0,
                              options: .transitionCrossDissolve,
                              animations: {
                self.imgBackground.image = image
                self.imgBackground.alpha = 1.0
            }, completion: { finished in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.imgBackgroundTop.constant = self.topbarHeight()
                    let viewWidth = UIScreen.main.bounds.size.width / 2
                    let ratio = image!.size.width / image!.size.height
                    let newHeight = viewWidth / ratio
                    
                    self.imgBackgroundHeight.constant = newHeight
                    self.imgBackgroundWidth.constant = viewWidth
                    UIView.animate(withDuration: 3.0) {
                        self.view.layoutIfNeeded()
                    } completion: { finished in
                        self.imgBackgroundPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.imgBackgroundPanHandler(_:)))
                        self.imgBackgroundPanGesture?.delegate = self
                        self.imgBackgroundPinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.imgBackgroundPinchHandler(_:)))
                        self.imgBackgroundPinchGesture?.delegate = self
                        self.imgBackground.addGestureRecognizer(self.imgBackgroundPanGesture!)
                        self.imgBackground.addGestureRecognizer(self.imgBackgroundPinchGesture!)
                        
                        self.viewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapHandler(_:)))
                        self.view.addGestureRecognizer(self.viewTapGesture!)
                    }
                }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                    UIView.animate(withDuration: 3.0) {
//                        self.viewImgBackgroundOpacity.alpha = CGFloat(self.backgroundBrightness)
//                    } completion: { finished in
//                        if image != nil {
//                            self.showBrightnessOption()
//                        }
//                        else {
//                            self.hideBrightnessOption()
//                        }
//                    }
//                }
            })
        }
        else {
            UIView.transition(with: self.imgBackground,
                              duration: 3.0,
                              options: .transitionCrossDissolve,
                              animations: {
                self.imgBackground.image = image
            }, completion: { finished in
                if self.imgBackgroundPanGesture != nil {
                    self.imgBackground.removeGestureRecognizer(self.imgBackgroundPanGesture!)
                }
                if self.imgBackgroundPinchGesture != nil {
                    self.imgBackground.removeGestureRecognizer(self.imgBackgroundPinchGesture!)
                }
                if self.viewTapGesture != nil {
                    self.view.removeGestureRecognizer(self.viewTapGesture!)
                }
                self.imgBackground.isHidden = true
                self.imgBackgroundTop.constant = 0
                self.imgBackgroundWidth.constant = UIScreen.main.bounds.size.width
                self.imgBackgroundHeight.constant = UIScreen.main.bounds.size.height
                self.view.layoutIfNeeded()
//                if image != nil {
//                    self.showBrightnessOption()
//                }
//                else {
//                    self.hideBrightnessOption()
//                }
            })
        }
    }
    
    @objc func viewTapHandler(_ gesture: UITapGestureRecognizer) {
        self.imgBackground.transform = .identity
    }
    
    @objc func imgBackgroundPinchHandler(_ gesture: UIPinchGestureRecognizer) {
        if let view = gesture.view {
            view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
        }
    }
    
    @objc func imgBackgroundPanHandler(_ gesture: UIPanGestureRecognizer) {
        guard let targetView = gesture.view else { return }
        let translation = gesture.translation(in: self.view)
        targetView.center = CGPoint(x: targetView.center.x + translation.x, y: targetView.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
//        let location = gesture.location(in: self.view)
//        let draggedView = gesture.view
//        draggedView?.center = location
//
        if gesture.state == .ended {
            if self.imgBackground.frame.midX >= self.view.layer.frame.width / 2 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    let transformedBounds = self.imgBackground.bounds.applying(self.imgBackground.transform)
                    self.imgBackground.center.x = self.view.layer.frame.width - (transformedBounds.size.width / 2)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                    let transformedBounds = self.imgBackground.bounds.applying(self.imgBackground.transform)
                    self.imgBackground.center.x = transformedBounds.size.width / 2
                }, completion: nil)
            }
        }
    }
    
    func topbarHeight() -> CGFloat {
        var top = self.navigationController?.navigationBar.frame.height ?? 0.0
        top += UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return top
    }
    
    func showAddPhotoInviteDialog() {
        if !UserDefaultsManager.isInvitePhotoDialogShown() {
            let arrayAIQuestions = self.boswellConversationHistoryDisplay.filter({$0.isAddToHistory == true && $0.role == .assistant && $0.isError == false})
            if arrayAIQuestions.count == 3 && !BoswellInterviewHelper.isUnusedPhotosAvailable(isParentPhoto: AppData.shared.config.isSilverMode)  {
                UserDefaultsManager.saveIsInvitePhotoDialogShown(flag: true)
                let alert = UIAlertController(title: "Include Photos?", message: "Boswell can ask you questions about photos in your photo library. Would you like to add photos now to start that process?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
                    self.stopUserRecordingIfAnyAction()
                    self.openBackgroundScreen(isParentPhoto: AppData.shared.config.isSilverMode, isFromParentProfile: false)
                }
                let noAction = UIAlertAction(title: "Not now", style: .cancel) { action in
                    Utility.showAlert(title: "", message: "You can add photos anytime from the Menu (choose \"Select Photos\")", vc: self)
                }
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.present(alert, animated: true)
            }
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
