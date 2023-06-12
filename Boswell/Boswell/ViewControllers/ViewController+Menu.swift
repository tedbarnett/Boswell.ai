//
//  ViewController+Menu.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//

import UIKit
import AVFoundation
import Speech
import Foundation

extension ViewController {
    // Open Menu from navigation
    @objc func btnMenuAction(_ sender: UIButton) {
        //self.dismissBrightnessControl()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopupMenuViewController") as! PopupMenuViewController
        vc.modalPresentationStyle = .popover
        vc.delegate = self
        if let popover = vc.popoverPresentationController {
            let viewForSource = sender as UIView
            popover.sourceView = viewForSource
            // the position of the popover where it's showed
            popover.sourceRect = viewForSource.bounds
            // the size you want to display
            vc.preferredContentSize = CGSizeMake(240,240)
            popover.delegate = self
        }
        present(vc, animated: true)
    }
    
    // Open update API key screen. isGPTCall means call GPT API after enter key.
    func openAIAPIKeyScreen(isGPTCall: Bool = true) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OpenAIAPIViewController") as! OpenAIAPIViewController
        vc.isRequiredGPTCall = isGPTCall
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    // Open save appearance screen.
    func openAppearanceScreen() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppearanceViewController") as! AppearanceViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    // Open Profile screen.
    func openProfileScreen(isParentProfile: Bool = false) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.delegate = self
        vc.isParentProfile = isParentProfile
        if isParentProfile {
            vc.firstname = UserDefaultsManager.getParentFirstname()
            vc.selectedDate = UserDefaultsManager.getParentBirthdate()
        }
        else {
            vc.firstname = UserDefaultsManager.getFirstname()
            vc.selectedDate = UserDefaultsManager.getBirthdate()
        }
        self.present(vc, animated: true)
    }
    
    // Open Boswell Mode Selection Screen.
    func openModeSelectionScreen(sourceView: UIView) {
        //self.dismissBrightnessControl()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BoswellModeViewController") as! BoswellModeViewController
        vc.modalPresentationStyle = .popover
        vc.delegate = self
        if let popover = vc.popoverPresentationController {
            let viewForSource = sourceView
            popover.sourceView = viewForSource
            // the position of the popover where it's showed
            popover.sourceRect = viewForSource.bounds
            // the size you want to display
            vc.preferredContentSize = CGSizeMake(180,141)
            popover.delegate = self
        }
        present(vc, animated: true)
    }
    
    // Open Birthdate screen.
    func openBackgroundScreen(isParentPhoto: Bool, isFromParentProfile: Bool) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BackgroundViewController") as! BackgroundViewController
        vc.delegate = self
        vc.isParentPhoto = isParentPhoto
        vc.isFromParentProfile = isFromParentProfile
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Open Audio Playback screen.
    func openAudioPlaybackScreen(audioURL: URL) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AudioPlaybackViewController") as! AudioPlaybackViewController
        vc.audioURL = audioURL
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    // Open Video Playback screen.
    func openVideoInterviewScreen() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoInterviewViewController") as! VideoInterviewViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // Open Interview List screen.
    func openInterviewListScreen(audioURL: URL?) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "InterviewListViewController") as! InterviewListViewController
        vc.firtAudioURL = audioURL
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSwitchModeLabel() {
        let message = "Switched to '\(AppData.shared.config.getTitleFromMode())' mode..."
        self.addRow(content: message, role: nil, isAddToHisoty: false)
        listeningStatus.text = message
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.listeningStatus.text = ""
        }
    }
    
    func startBoswellInterview(birthdate: Date, firstname: String) {
        self.setBackgroundImage()
        let content = boswellInterviewHelper.getBoswellAIPrompst(birthdate: birthdate, firstname: firstname)
        self.addRow(content: content, role: .system, isDisplay: false)
        self.sendToChatGPT(apiModel: .ChatGPT_4)
    }
}

extension ViewController: BackgroundViewControllerDelegate {
    func backgroundViewControllerDidUpdate(isUpdated: Bool, isParentPhoto: Bool, isFromParentProfile: Bool) {
        if isFromParentProfile {
            self.openProfileScreen(isParentProfile: true)
        }
        else if AppData.shared.config.mode == .Boswell && isUpdated {
            if BoswellInterviewHelper.isUnusedPhotosAvailable(isParentPhoto: isParentPhoto) {
                if let _ = boswellConversationHistory.firstIndex(where: {$0.role == .system && ($0.content ?? "").lowercased().contains(boswellInterviewHelper.askPhotoQuestions.lowercased())}) {
                    self.addRow(content: boswellInterviewHelper.continueAskPhotoQuestions, role: .user, isDisplay: false)
                }
                else {
                    self.addRow(content: boswellInterviewHelper.askPhotoQuestions, role: .system, isDisplay: false)
                }
            }
            else {
                self.addRow(content: boswellInterviewHelper.stopPhotoQuestions, role: .user, isDisplay: false)
            }
        }
        
    }
}

extension ViewController: BoswellModeViewControllerDelegate {
    func boswellModeViewControllerDidSaveSuccessfully(isUpdateMode: Bool, previousMode: BoswellModeModel.BoswellMode) {
        self.updateAppMode(isUpdateMode: isUpdateMode, previousMode: previousMode)
    }
    
    func updateAppMode(isUpdateMode: Bool, previousMode: BoswellModeModel.BoswellMode) {
        self.menuButton.setTitle(AppData.shared.config.getTitleFromMode(), for: .normal)
        if isUpdateMode {
            self.stopUserRecordingIfAnyAction()
            if !self.isPlayingIntroAudio {
                self.stopAudio()
            }
            self.updateRecordButton(enable: self.recordButton.isEnabled, title: self.getRecordButtonTitle())
            if AppData.shared.config.mode == .Boswell {
                let birthdate: Date? = AppData.shared.config.isSilverMode ? UserDefaultsManager.getParentBirthdate() : UserDefaultsManager.getBirthdate()
                let firstname: String? = AppData.shared.config.isSilverMode ? UserDefaultsManager.getParentFirstname() : UserDefaultsManager.getFirstname()
                if let tBirthdate = birthdate, let tFirstname = firstname {
                    if self.boswellConversationHistoryDisplay.count > 0 {
                        if let last = self.boswellConversationHistoryDisplay.last, last.role != .assistant, last.isError != false {
                            self.startBoswellInterview(birthdate: tBirthdate, firstname: tFirstname)
                        }
                    }
                    else {
                        self.startBoswellInterview(birthdate: tBirthdate, firstname: tFirstname)
                    }
                }
                else {
                    self.openProfileScreen(isParentProfile: AppData.shared.config.isSilverMode)
                }
            }
            else {
                self.setBackgroundImage()
                if previousMode == .Boswell {
                    self.updateRecordButton(enable: true, title: self.getRecordButtonTitle())
                }
                else {
                    self.showSwitchModeLabel()
                }
            }
            self.tableViewChat.reloadData()
        }
    }
}

extension ViewController: ProfileViewControllerDelegate {
    func profileViewControllerDelegateDidEnter(birthdate: Date, firstname: String, isUpdated: Bool, isParentProfile: Bool, isSilveMode: Bool) {
        if isParentProfile {
            UserDefaultsManager.saveParentBirth(date: birthdate)
            UserDefaultsManager.saveParentFirst(name: firstname)
            if AppData.shared.config.mode == .Boswell && isUpdated {
                self.startBoswellInterview(birthdate: birthdate, firstname: firstname)
            }
        }
        else {
            if isUpdated {
                if AppData.shared.config.isSilverMode != isSilveMode {
                    AppData.shared.config.mode = .Boswell
                    self.stopAudio()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigation") as! UINavigationController
                    vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    self.present(vc, animated: true)
                }
                else {
                    if AppData.shared.config.mode == .Boswell {
                        self.startBoswellInterview(birthdate: birthdate, firstname: firstname)
                    }
                }
                AppData.shared.config.isSilverMode = isSilveMode
                UserDefaultsManager.saveBirth(date: birthdate)
                UserDefaultsManager.saveFirst(name: firstname)
            }
        }
    }
    
    func profileViewControllerDelegateDidCancel(isParentProfile: Bool) {
        if isParentProfile {
            return
        }
        if AppData.shared.config.mode == .Boswell {
            if UserDefaultsManager.getBirthdate() == nil || UserDefaultsManager.getFirstname() == nil {
                AppData.shared.config.mode = .ChatGPT
                self.menuButton.setTitle(AppData.shared.config.getTitleFromMode(), for: .normal)
                listeningStatus.text = "switched to \(AppData.shared.config.getTitleFromMode()) mode.."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.listeningStatus.text = ""
                }
            }
        }
    }
    
    func profileViewControllerDidSelectPhotosForParent(birthdate: Date, firstname: String) {
        UserDefaultsManager.saveParentBirth(date: birthdate)
        UserDefaultsManager.saveParentFirst(name: firstname)
        self.openBackgroundScreen(isParentPhoto: true, isFromParentProfile: true)
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none // 3
    }
}

extension ViewController: PopupMenuViewControllerDelegate {
    // Menu press event
    func popupMenuViewControllerDidSelect(menu: String) {
        self.stopUserRecordingIfAnyAction()
//        if menu == MenuTitle.NewChat {
//            self.createNewChat()
//        }
//        else if menu == MenuTitle.OpenAIAPI {
//            self.openAIAPIKeyScreen(isGPTCall: false)
//        }
        if menu == MenuTitle.MyProfile {
            self.openProfileScreen()
        }
        else if menu == MenuTitle.Appearance {
            self.openAppearanceScreen()
        }
        else if menu == MenuTitle.Background {
            self.openBackgroundScreen(isParentPhoto: AppData.shared.config.isSilverMode, isFromParentProfile: false)
        }
        else if menu == MenuTitle.PlaybackInterview {
            Utility.showLoader(status: "Loading audio...")
            audioRecordManager.mergeAudioFiles(foldername: AppData.shared.config.isSilverMode ? FolderName.PlaybackAudioParents : FolderName.PlaybackAudio, filename: Utility.getInterviewFilename()) { audioPlaybackFileURL, error in
                DispatchQueue.main.async {
                    Utility.hideLoader()
                    if AudioRecorderManager.getAllInterviewFrom(directory: AppData.shared.config.isSilverMode ? FolderName.BoswellParents : FolderName.Boswell).count > 0 {
                        self.openInterviewListScreen(audioURL: audioPlaybackFileURL)
                    }
                    else {
                        if let url = audioPlaybackFileURL {
                            self.openAudioPlaybackScreen(audioURL: url)
                        }
                        else {
                            Utility.showAlert(title: "", message: error?.localizedDescription ?? "You have not yet recorded any interview questions with Boswell. Switch to Boswell mode (tap the title area) and answer a few of Boswell's questions first.", vc: self)
                        }
                    }
                }
            }
        }
        else if menu == MenuTitle.CreateVideo {
            Task {
                do {
                    Utility.showLoader(status: "Creating Video...")
                    try await VideoManager.shared.createVideoInterView(history: self.boswellConversationHistoryDisplay)
                    Utility.hideLoader()
                    if VideoManager.shared.getAllVideoList().count > 0 {
                        self.openVideoInterviewScreen()
                    }
                }
                catch let error {
                    Utility.hideLoader()
                    print(error)
                }
            }
        }
//        else if menu == MenuTitle.InterviewParent {
//            self.openProfileScreen(isParentProfile: true)
//        }
//        else if menu == MenuTitle.FreshStart {
//            self.stopAudio()
//            UserDefaultsManager.clearAllData()
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "MainNavigation") as! UINavigationController
//            vc.modalPresentationStyle = .fullScreen
//            vc.modalTransitionStyle = .crossDissolve
//            self.present(vc, animated: true)
//        }
    }
}

extension ViewController: OpenAIAPIViewControllerDelegate {
    // Update API key
    func openAIAPIViewControllerDidSave(isGPTCall: Bool) {
        if let key = UserDefaultsManager.getOpenAIAPIKey() {
            APIManager.shared.openAI_APIKey = key
        }
        if AppData.shared.config.mode == .Boswell {
            self.listeningStatus.text = "Your Personal Biographer"
        }
        else {
            self.listeningStatus.text = AppData.shared.config.apiModel == .ChatGPT_4 ? "(GPT-4)" : "(GPT-3.5)"
        }
        if isGPTCall {
            if AppData.shared.config.mode == .CreateImage {
                if let lastPrompt = self.conversationHistory.last, lastPrompt.role == .user, let content = lastPrompt.content, content != "" {
                    self.createImage(text: content) // Call create image GPT API if create image check box is selected
                }
            }
            else {
                self.sendToChatGPT(apiModel: .ChatGPT_4)
            }
        }
        else {
            if AppData.shared.config.mode == .Boswell {
                if let lastPrompt = self.boswellConversationHistory.last, lastPrompt.role == .assistant, lastPrompt.mode == .Boswell, lastPrompt.isError == true {
                    self.sendToChatGPT(apiModel: .ChatGPT_4)
                }
            }
        }
    }
}
