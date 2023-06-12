//
//  AIPromptModel.swift
//  Boswell
//
//  Created by MyMac on 02/05/23.
//

import UIKit

class AIPromptModel: NSObject {
    enum Role: String {
        case system
        case assistant
        case user
    }
    var promptId: String = UUID().uuidString
    var role: Role?
    var content: String?
    var isDisplay: Bool = true
    var isAddToHistory: Bool = true
    var image: UIImage?
    var isError: Bool = false
    var backgroundImage: UIImage?
    var mode: BoswellModeModel.BoswellMode = .ChatGPT
}
