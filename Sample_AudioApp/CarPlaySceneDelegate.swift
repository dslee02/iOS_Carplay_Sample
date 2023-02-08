//
//  CarPlaySceneDelegate.swift
//  Sample_AudioApp
//
//  Created by dasol lee on 2023/02/08.
//

import Foundation
import CarPlay

class CarPlaySceneDelegate: UIResponder {
    static let configurationName = "CarPlayScene Configuration"
    var interfaceController: CPInterfaceController?
}

extension CarPlaySceneDelegate: CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        let item = CPListItem(text: "My Text", detailText: "My detail text")
        let section = CPListSection(items: [item])
        let listTemplate = CPListTemplate(title: "Albums", sections: [section])
        interfaceController.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
}
