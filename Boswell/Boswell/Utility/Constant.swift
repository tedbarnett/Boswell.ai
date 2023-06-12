//
//  Constant.swift
//  Boswell
//
//  Created by MyMac on 17/04/23.
//

import Foundation

struct UserDefaultKey {
    static let kOpenAI_APIKey = "OpenAI_APIKey"
    static let kBirthdate = "Birthdate"
    static let kFirstname = "Firstname"
    static let kParentBirthdate = "ParentBirthdate"
    static let kParentFirstname = "ParentFirstname"
    static let kAppMode = "AppMode"
    static let kAppApiModel = "AppApiModel"
    static let kShownImages = "ShownImages"
    static let kParentShownImages = "ParentShownImages"
    static let IsAppLaunchFirstTime = "IsAppLaunchFirstTime"
    static let IsInvitePhotoDialogShown = "IsInvitePhotoDialogShown"
    struct Appearance {
        struct UserPrompts {
            static let FontSize = "UserPrompts_FontSize"
            static let FontWeight = "UserPrompts_FontWeight"
            static let FontColor = "UserPrompts_FontColor"
        }
        struct AIResponse {
            static let FontSize = "AIResponse_FontSize"
            static let FontWeight = "AIResponse_FontWeight"
            static let FontColor = "AIResponse_FontColor"
        }
    }
}

// Update Default Font Appearance Constant
struct DeafultFontAppearance {
    struct UserPrompts {
        static let FontSize: Float = 22.0 // 8.0 to 30.0
        static let FontWeight = "bold" // "bold" or "normal"
        static let FontColor = "#aaaaaa" // Any hex color
    }
    struct AIResponse {
        static let FontSize: Float = 22.0 // 8.0 to 30.0
        static let FontWeight = "normal" // "bold" or "normal"
        static let FontColor = "#f3c567" // Any hex color
    }
}

struct GPTAPIModel {
    static let GPT_3_5_Turbo = "gpt-3.5-turbo"
    static let GPT_4 = "gpt-4"
}

struct MenuTitle {
    static let MyProfile = "My Profile"
    static let Appearance = "Appearance"
    static let Background = "Select Photos"
    static let PlaybackInterview = "Play Interview Audio"
    static let CreateVideo = "Create video"
    //static let InterviewParent = "Interview Parent"
    
    //    static let OpenAIAPI = "OpenAI API"
    //    static let FreshStart = "Fresh Start"
    //    static let NewChat = "Clear Chat History"
}

struct GPT_API {
    static let BASE_URL = "https://api.openai.com/v1"
    static let CHAT_GPT_4 = GPT_API.BASE_URL + "/chat/completions"
    static let GPT_3_5_TURBO = GPT_API.BASE_URL + "/engines/text-davinci-003/completions"
    static let CREATE_IMAGE = GPT_API.BASE_URL + "/images/generations"
}

struct FolderName {
    static let BackgroundPhotos = "BackgroundPhotos"
    static let BackgroundForParentPhotos = "BackgroundForParentPhotos"
    static let PlaybackAudio = "PlaybackAudio"
    static let Boswell = "Boswell"
    static let PlaybackAudioParents = "PlaybackAudioParents"
    static let BoswellParents = "BoswellParents"
    static let VideoInterview = "VideoInterview"
}

let QuestionCountForInvitePhotoDialog: Int = 3
