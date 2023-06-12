//
//  BoswellInterviewHelper.swift
//  Boswell
//
//  Created by MyMac on 22/05/23.
//

import UIKit

class BoswellInterviewHelper: NSObject {
    var corePromptContent: String = ""
    var interviewStart: String = ""
    var interviewContinue: String = ""
    var askPhotoQuestions: String = ""
    var stopPhotoQuestions: String = ""
    var continueAskPhotoQuestions: String = ""
    var isFirstTime: Bool = true
    var aiPrompts: [String: Any] = {
        guard let plistPath = Bundle.main.path(forResource: "prompts", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath) as? [String: Any] else {
            return [:]
        }
        return plistDict
    }()

    override init() {
        super.init()
        corePromptContent = aiPrompts["corePromptContent"] as? String ?? ""
        interviewStart = aiPrompts["interviewStart"] as? String ?? ""
        interviewContinue = aiPrompts["interviewContinue"] as? String ?? ""
        askPhotoQuestions = aiPrompts["askPhotoQuestions"] as? String ?? ""
        stopPhotoQuestions = aiPrompts["stopPhotoQuestions"] as? String ?? ""
        continueAskPhotoQuestions = aiPrompts["continueAskPhotoQuestions"] as? String ?? ""
    }
    
    func getBoswellAIPrompst(birthdate: Date, firstname: String) -> String {
        corePromptContent = aiPrompts["corePromptContent"] as? String ?? ""
        interviewStart = aiPrompts["interviewStart"] as? String ?? ""
        interviewContinue = aiPrompts["interviewContinue"] as? String ?? ""
        if BoswellInterviewHelper.isUnusedPhotosAvailable(isParentPhoto: AppData.shared.config.isSilverMode) {
            corePromptContent = corePromptContent + askPhotoQuestions
        }
        let calendarBirthdate = Calendar.current.dateComponents([.day, .year, .month], from: birthdate)
        let currentDate = Calendar.current.dateComponents([.day, .year, .month], from: Date())
        if let birthYear = calendarBirthdate.year, let currentYear = currentDate.year {
            if AppData.shared.config.isSilverMode {
                UserDefaultsManager.saveParentBirth(date: birthdate)
                UserDefaultsManager.saveParentFirst(name: firstname)
            }
            else {
                UserDefaultsManager.saveBirth(date: birthdate)
                UserDefaultsManager.saveFirst(name: firstname)
            }
            var content: String = ""
            if self.isFirstTime {
                self.isFirstTime = false
                let ageOld = currentYear - birthYear // I am {ageOld} years old now
                let upperRange = ageOld - 10
                let lowerRange = 3
                let userAgeForQuestion = Int.random(in: lowerRange..<upperRange) // (lowerRange - upperRange)
                let yearForQuestion = birthYear + userAgeForQuestion
                
                interviewStart = interviewStart.replacingOccurrences(of: "{firstname}", with: firstname)
                interviewStart = interviewStart.replacingOccurrences(of: "{userAgeForQuestion}", with: "\(userAgeForQuestion)")
                interviewStart = interviewStart.replacingOccurrences(of: "{yearForQuestion}", with: "\(yearForQuestion)")
                content = interviewStart + corePromptContent
            }
            else {
                interviewContinue = interviewContinue.replacingOccurrences(of: "{firstname}", with: firstname)
                interviewContinue = interviewContinue.replacingOccurrences(of: "{birthYear}", with: "\(birthYear)")
                content = interviewContinue + corePromptContent
            }
            return content
        }
        return ""
    }
    
    class func getBackgroundImageURLs(isParentPhoto: Bool) -> [URL] {
        if let dirPath = Utility.getDirectoryURL(name: isParentPhoto ? FolderName.BackgroundForParentPhotos : FolderName.BackgroundPhotos) {
            do {
                // Get the directory contents urls (including subfolders urls)
                let urls = try FileManager.default.contentsOfDirectory(at: dirPath, includingPropertiesForKeys: nil)
                return urls
            }
            catch let error {
                print(error)
            }
        }
        return []
    }

    class func isUnusedPhotosAvailable(isParentPhoto: Bool) -> Bool {
        let urls = BoswellInterviewHelper.getBackgroundImageURLs(isParentPhoto: isParentPhoto)
        if urls.count > 0 {
            let shownImagesName = UserDefaultsManager.getShownImagesName(isParentPhoto: isParentPhoto)
            let newURLs = urls.filter { url in
                if let _ = shownImagesName.firstIndex(where: {$0 == url.lastPathComponent}) {
                    return false
                }
                else {
                    return true
                }
            }
            if newURLs.count > 0 {
                return true
            }
        }
        return false
    }
    
    class func markUsedAndUnused(url: URL, isParentPhoto: Bool) {
        var shownImagesName = UserDefaultsManager.getShownImagesName(isParentPhoto: isParentPhoto)
        if let index = shownImagesName.firstIndex(where: {$0 == url.lastPathComponent}) {
            shownImagesName.remove(at: index)
        }
        else {
            shownImagesName.append(url.lastPathComponent)
        }
        UserDefaultsManager.saveShownImages(name: shownImagesName, isParentPhoto: isParentPhoto)
    }
    
    class func isPhotoUsed(url: URL, isParentPhoto: Bool) -> Bool {
        let shownImagesName = UserDefaultsManager.getShownImagesName(isParentPhoto: isParentPhoto)
        if let _ = shownImagesName.firstIndex(where: {$0 == url.lastPathComponent}) {
            return true
        }
        else {
            return false
        }
    }
}
