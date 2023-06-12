//
//  BoswellModeModel.swift
//  Boswell
//
//  Created by MyMac on 25/04/23.
//

import UIKit

class BoswellModeModel: NSObject {
    enum BoswellMode: String {
        case Boswell
        case ChatGPT
        case CreateImage
    }
    
    enum APIModel: String {
        case ChatGPT_4
        case ChatGPT_3_5
    }

    var mode: BoswellMode = .Boswell
    var apiModel: APIModel = .ChatGPT_4
    var isSilverMode: Bool = false
    
    override init() {
        super.init()
        self.mode = UserDefaultsManager.getAppMode()
        self.apiModel = UserDefaultsManager.getAppApiModel()
        self.isSilverMode = false
    }
    
    init(mode: BoswellMode, apiModel: APIModel) {
        self.mode = mode
        self.apiModel = apiModel
    }
    
    func save(mode: BoswellMode) {
        self.mode = mode
        UserDefaultsManager.saveApp(mode: mode)
    }
    
    func saveApi(model: APIModel) {
        self.apiModel = model
        UserDefaultsManager.saveAppApi(model: model)
    }
    
    func getTitleFromMode() -> String {
        var title: String = ""
        if self.mode == .CreateImage {
            title = "Create Image"
        }
        else if self.mode == .ChatGPT {
            title = "ChatGPT"
        }
        else {
            title = "Boswell"
        }
        return title
    }
}
