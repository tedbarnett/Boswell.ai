//
//  MenuModel.swift
//  Boswell
//
//  Created by MyMac on 18/04/23.
//

import UIKit

struct MenuModel {
    var menuTitle: String?
    var menuIcon: String?
    
    init(menuTitle: String? = nil, menuIcon: String? = nil) {
        self.menuTitle = menuTitle
        self.menuIcon = menuIcon
    }
    
    static func getMenuList() -> [MenuModel] {
        let menu1 = MenuModel(menuTitle: MenuTitle.MyProfile, menuIcon: "")
        let menu2 = MenuModel(menuTitle: MenuTitle.Appearance, menuIcon: "")
        let menu3 = MenuModel(menuTitle: MenuTitle.Background, menuIcon: "")
        let menu4 = MenuModel(menuTitle: MenuTitle.PlaybackInterview, menuIcon: "")
        let menu5 = MenuModel(menuTitle: MenuTitle.CreateVideo, menuIcon: "")
        //        let menu5 = MenuModel(menuTitle: MenuTitle.NewChat, menuIcon: "")
        //        let menu7 = MenuModel(menuTitle: MenuTitle.FreshStart, menuIcon: "")
        //        let menu1 = MenuModel(menuTitle: MenuTitle.OpenAIAPI, menuIcon: "")
        return [menu1, menu2, menu3, menu4, menu5]
    }
}
