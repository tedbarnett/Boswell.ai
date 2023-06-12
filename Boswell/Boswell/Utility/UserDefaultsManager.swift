//
//  UserDefaultsManager.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//
// This class is useful for storing data in Userdefault(Device Local)

import UIKit

class UserDefaultsManager: NSObject {
    /// Save the given `OpenAI API key` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveOpenAI(APIKey:<API Key>)
    /// ```
    /// - Parameters:
    ///     - APIKey: This is required parameters and it must be a string.
    static func saveOpenAI(APIKey: String) {
        UserDefaults.standard.set(APIKey, forKey: UserDefaultKey.kOpenAI_APIKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Get `OpenAI API key` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getOpenAIAPIKey()
    /// ```
    /// - Returns: Return `OpenAI API key` from UserDefaults and it's a string.
    static func getOpenAIAPIKey() -> String? {
        let key = UserDefaults.standard.value(forKey: UserDefaultKey.kOpenAI_APIKey) as? String
        return key
    }

    /// Save the given user `Birthdate` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveBirth(date: <Date Object>)
    /// ```
    /// - Parameters:
    ///     - date: This is required parameters and it must be a Date.
    static func saveBirth(date: Date) {
        UserDefaults.standard.set(date, forKey: UserDefaultKey.kBirthdate)
        UserDefaults.standard.synchronize()
    }
    
    /// Get user `Birthdate` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getBirthdate()
    /// ```
    /// - Returns: Return user `Birthdate` from UserDefaults and it's a Date.
    static func getBirthdate() -> Date? {
        let date = UserDefaults.standard.value(forKey: UserDefaultKey.kBirthdate) as? Date
        return date
    }
    
    /// Save the given user `Firstname` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveFirst(name: String)
    /// ```
    /// - Parameters:
    ///     - name: This is required parameters and it must be a String.
    static func saveFirst(name: String) {
        UserDefaults.standard.set(name, forKey: UserDefaultKey.kFirstname)
        UserDefaults.standard.synchronize()
    }
    
    /// Get user `Firstname` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getFirstname()
    /// ```
    /// - Returns: Return user `Firstname` from UserDefaults and it's a String.
    static func getFirstname() -> String? {
        let name = UserDefaults.standard.value(forKey: UserDefaultKey.kFirstname) as? String
        return name
    }
    
    /// Save the given user prompt font `Size` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveUserPromptFont(size: 17.0)
    /// ```
    /// - Parameters:
    ///     - size: This is required parameters and it must be a float.
    static func saveUserPromptFont(size: Float) {
        UserDefaults.standard.set(size, forKey: UserDefaultKey.Appearance.UserPrompts.FontSize)
        UserDefaults.standard.synchronize()
    }
    
    /// Save the given user prompt font `Weight` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveUserPromptFont(weight: "normal")
    /// ```
    /// - Parameters:
    ///     - weight: This is required parameters and it must be a string.
    static func saveUserPromptFont(weight: String) {
        UserDefaults.standard.set(weight, forKey: UserDefaultKey.Appearance.UserPrompts.FontWeight)
        UserDefaults.standard.synchronize()
    }
    
    /// Save the given user prompt font `Color` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveUserPromptFont(color: "#000000")
    /// ```
    /// - Parameters:
    ///     - color: This is required parameters and it must be a string and value should be a hex string color like #ffffff.
    static func saveUserPromptFont(color: String) {
        UserDefaults.standard.set(color, forKey: UserDefaultKey.Appearance.UserPrompts.FontColor)
        UserDefaults.standard.synchronize()
    }
    
    /// Get user promt `Font Size` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getUserPromptFontSize()
    /// ```
    /// - Returns: Return user promt `Font Size` from UserDefaults and it's a Float. If not found then returns default value 22.0
    static func getUserPromptFontSize() -> Float {
        let size = UserDefaults.standard.value(forKey: UserDefaultKey.Appearance.UserPrompts.FontSize) as? Float
        return size ?? DeafultFontAppearance.UserPrompts.FontSize
    }
    
    /// Get user promt `Font Weight` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getUserPromptFontWeight()
    /// ```
    /// - Returns: Return user promt `Font Weight` from UserDefaults and it's a String. If not found then returns default value "bold"
    static func getUserPromptFontWeight() -> String {
        let weight = UserDefaults.standard.value(forKey: UserDefaultKey.Appearance.UserPrompts.FontWeight) as? String
        return weight ?? DeafultFontAppearance.UserPrompts.FontWeight
    }
    
    /// Get user promt `Font Color` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getUserPromptFontColor()
    /// ```
    /// - Returns: Return user promt `Font Color` from UserDefaults and it's a String. If not found then returns default color "#aaaaaa"
    static func getUserPromptFontColor() -> String {
        let color = UserDefaults.standard.value(forKey: UserDefaultKey.Appearance.UserPrompts.FontColor) as? String
        return color ?? DeafultFontAppearance.UserPrompts.FontColor
    }
    
    /// Save the given AI prompt font `Size` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveAIResponseFont(size: 17.0)
    /// ```
    /// - Parameters:
    ///     - size: This is required parameters and it must be a float.
    static func saveAIResponseFont(size: Float) {
        UserDefaults.standard.set(size, forKey: UserDefaultKey.Appearance.AIResponse.FontSize)
        UserDefaults.standard.synchronize()
    }
    
    /// Save the given AI prompt font `Weight` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveAIResponseFont(weight: "normal")
    /// ```
    /// - Parameters:
    ///     - weight: This is required parameters and it must be a string.
    static func saveAIResponseFont(weight: String) {
        UserDefaults.standard.set(weight, forKey: UserDefaultKey.Appearance.AIResponse.FontWeight)
        UserDefaults.standard.synchronize()
    }
    
    /// Save the given AI prompt font `Color` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveAIResponseFont(color: "#000000")
    /// ```
    /// - Parameters:
    ///     - color: This is required parameters and it must be a string and value should be a hex string color like #ffffff.
    static func saveAIResponseFont(color: String) {
        UserDefaults.standard.set(color, forKey: UserDefaultKey.Appearance.AIResponse.FontColor)
        UserDefaults.standard.synchronize()
    }
    
    /// Get AI promt `Font Size` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getAIResponseFontSize()
    /// ```
    /// - Returns: Return AI promt `Font Size` from UserDefaults and it's a Float. If not found then returns default value 22.0
    static func getAIResponseFontSize() -> Float {
        let size = UserDefaults.standard.value(forKey: UserDefaultKey.Appearance.AIResponse.FontSize) as? Float
        return size ?? DeafultFontAppearance.AIResponse.FontSize
    }
    
    /// Get AI promt `Font Weight` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getAIResponseFontWeight()
    /// ```
    /// - Returns: Return AI promt `Font Weight` from UserDefaults and it's a String. If not found then returns default value "normal"
    static func getAIResponseFontWeight() -> String {
        let weight = UserDefaults.standard.value(forKey: UserDefaultKey.Appearance.AIResponse.FontWeight) as? String
        return weight ?? DeafultFontAppearance.AIResponse.FontWeight
    }
    
    /// Get AI promt `Font Color` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getAIResponseFontColor()
    /// ```
    /// - Returns: Return AI promt `Font Color` from UserDefaults and it's a String. If not found then returns default color "#10a37f"
    static func getAIResponseFontColor() -> String {
        let color = UserDefaults.standard.value(forKey: UserDefaultKey.Appearance.AIResponse.FontColor) as? String
        return color ?? DeafultFontAppearance.AIResponse.FontColor
    }
    
    /// Save the given app `Mode` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveApp(mode: .ChatGPT)
    /// ```
    /// - Parameters:
    ///     - mode: This is required parameters and it must be a `BoswellModeModel.BoswellMode` enum.
    ///     mode should be .Boswell, .ChatGPT or .CreateImage
    static func saveApp(mode: BoswellModeModel.BoswellMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: UserDefaultKey.kAppMode)
        UserDefaults.standard.synchronize()
    }
    
    /// Save the given app `API Model` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveAppApi(model: .ChatGPT_4)
    /// ```
    /// - Parameters:
    ///     - model: This is required parameters and it must be a `BoswellModeModel.APIModel` enum.
    ///     mode should be .ChatGPT_4 or .ChatGPT_3_5
    static func saveAppApi(model: BoswellModeModel.APIModel) {
        UserDefaults.standard.set(model.rawValue, forKey: UserDefaultKey.kAppApiModel)
        UserDefaults.standard.synchronize()
    }
    
    
    /// Get app `Mode` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getAppMode()
    /// ```
    /// - Returns: Return app`Mode` from UserDefaults and it's a `BoswellModeModel.BoswellMode` enu. If not found then returns default mode `.ChatGPT`
    static func getAppMode() -> BoswellModeModel.BoswellMode {
        if let mode = UserDefaults.standard.value(forKey: UserDefaultKey.kAppMode) as? String {
            return BoswellModeModel.BoswellMode(rawValue: mode) ?? .Boswell
        }
        return .Boswell
    }
    
    /// Get app `API Model` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getAppApiModel()
    /// ```
    /// - Returns: Return app`API Model` from UserDefaults and it's a `BoswellModeModel.APIModel` enu. If not found then returns default mode `.ChatGPT_4`
    static func getAppApiModel() -> BoswellModeModel.APIModel {
        if let apiModel = UserDefaults.standard.value(forKey: UserDefaultKey.kAppApiModel) as? String {
            return BoswellModeModel.APIModel(rawValue: apiModel) ?? .ChatGPT_4
        }
        return .ChatGPT_4
    }
    
    /// Save the given user parent `Birthdate` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveParentBirth(date: <Date Object>)
    /// ```
    /// - Parameters:
    ///     - date: This is required parameters and it must be a Date.
    static func saveParentBirth(date: Date) {
        UserDefaults.standard.set(date, forKey: UserDefaultKey.kParentBirthdate)
        UserDefaults.standard.synchronize()
    }
    
    /// Get user parent `Birthdate` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getParentBirthdate()
    /// ```
    /// - Returns: Return user parent `Birthdate` from UserDefaults and it's a Date.
    static func getParentBirthdate() -> Date? {
        let date = UserDefaults.standard.value(forKey: UserDefaultKey.kParentBirthdate) as? Date
        return date
    }
    
    /// Save the given user parent `Firstname` to  UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.saveParentFirst(name: String)
    /// ```
    /// - Parameters:
    ///     - name: This is required parameters and it must be a String.
    static func saveParentFirst(name: String) {
        UserDefaults.standard.set(name, forKey: UserDefaultKey.kParentFirstname)
        UserDefaults.standard.synchronize()
    }
    
    /// Get user parent `Firstname` from UserDefaults.
    ///
    /// ```
    /// UserDefaultsManager.getParentFirstname()
    /// ```
    /// - Returns: Return user parent `Firstname` from UserDefaults and it's a String.
    static func getParentFirstname() -> String? {
        let name = UserDefaults.standard.value(forKey: UserDefaultKey.kParentFirstname) as? String
        return name
    }
    
    static func saveShownImages(name: [String], isParentPhoto: Bool) {
        UserDefaults.standard.set(name, forKey: isParentPhoto ? UserDefaultKey.kParentShownImages : UserDefaultKey.kShownImages)
        UserDefaults.standard.synchronize()
    }
    
    static func getShownImagesName(isParentPhoto: Bool) -> [String] {
        let imagesName = UserDefaults.standard.value(forKey: isParentPhoto ? UserDefaultKey.kParentShownImages : UserDefaultKey.kShownImages) as? [String] ?? []
        return imagesName
    }
    
    static func saveAppLaunchFlag(isFirstTime: Bool) {
        UserDefaults.standard.set(isFirstTime, forKey: UserDefaultKey.IsAppLaunchFirstTime)
        UserDefaults.standard.synchronize()
    }
    
    static func getAppLaunchFlag() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultKey.IsAppLaunchFirstTime)
    }
    
    static func saveIsInvitePhotoDialogShown(flag: Bool) {
        UserDefaults.standard.set(flag, forKey: UserDefaultKey.IsInvitePhotoDialogShown)
        UserDefaults.standard.synchronize()
    }
    
    static func isInvitePhotoDialogShown() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultKey.IsInvitePhotoDialogShown)
    }
    
    static func clearAllData() {
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.Appearance.UserPrompts.FontSize)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.Appearance.UserPrompts.FontWeight)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.Appearance.UserPrompts.FontColor)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.Appearance.AIResponse.FontSize)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.Appearance.AIResponse.FontWeight)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.Appearance.AIResponse.FontColor)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.kAppMode)
        UserDefaults.standard.removeObject(forKey: UserDefaultKey.kAppApiModel)
        UserDefaultsManager.saveAppLaunchFlag(isFirstTime: false)
        AppData.shared.config = BoswellModeModel()
    }
}
