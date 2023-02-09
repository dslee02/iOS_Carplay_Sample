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


// MARK: - CPTemplateApplicationSceneDelegate
extension CarPlaySceneDelegate: CPTemplateApplicationSceneDelegate {
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        
        let tabTemplates = CPTabBarTemplate(templates: [audioTemplete(), favoriteTemplte(), frameworkUITemplete()])
        tabTemplates.delegate = self
        interfaceController.setRootTemplate(tabTemplates, animated: true, completion: nil)
    }
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
}


// MARK: - CPTabBarTemplateDelegate
extension CarPlaySceneDelegate: CPTabBarTemplateDelegate {
    func tabBarTemplate(_ tabBarTemplate: CPTabBarTemplate, didSelect selectedTemplate: CPTemplate) {
        print("didSelect \(selectedTemplate.description)")
    }
}


// MARK: - Make Templete
extension CarPlaySceneDelegate {
    private func audioTemplete() -> CPListTemplate {
        var listItems = [CPListItem]()
        
        AudioFileManager.shred.list.forEach { audioFile in
            let item = CPListItem(text: audioFile.name, detailText: audioFile.detailText, image: UIImage(named: audioFile.thumbnail))
            item.handler = { playlistItem, completion in
                AudioManager.shared.play(audioFile)
                let nowPlayingTemplate = CPNowPlayingTemplate.shared
                let playingImageButton = CPNowPlayingImageButton(image: UIImage(named: audioFile.thumbnail)!)
                nowPlayingTemplate.updateNowPlayingButtons([playingImageButton])
                nowPlayingTemplate.isUpNextButtonEnabled = true
                nowPlayingTemplate.isAlbumArtistButtonEnabled = true
                nowPlayingTemplate.isAccessibilityElement = true
                self.interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)
                completion()
            }
            listItems.append(item)
        }
        
        
        let sectionA = CPListSection(items: listItems)
        let template = CPListTemplate(title: "오디오 목록", sections: [sectionA])
        template.tabImage = UIImage(named: "radio")
        
        return template
    }
    
    private func favoriteTemplte() -> CPListTemplate {
        let itemB = CPListItem(text: "즐겨찾기 아이템 1", detailText: "My detail text", image: UIImage(named: "thumbnail"))
        let sectionB = CPListSection(items: [itemB])
        let template = CPListTemplate(title: "즐겨찾기", sections: [sectionB])
        template.tabImage = UIImage(named: "half_favorite")
        
        return template
    }
    
    private func frameworkUITemplete() -> CPListTemplate {
        let itemC = CPListItem(text: "즐겨찾기 아이템 1", detailText: "My detail text", image: UIImage(named: "thumbnail"))
        let sectionC = CPListSection(items: [itemC])
        let template = CPListTemplate(title: "UI 목록", sections: [sectionC])
        template.tabImage = UIImage(systemName: "building.columns")
        
        return template
    }
}
/**
 let itemA = CPGridButton(titleVariants: ["A"], image: UIImage(named: "thumbnail")!)
 let itemAA = CPGridButton(titleVariants: ["B"], image: UIImage(named: "thumbnail")!)
 let itemAAA = CPGridButton(titleVariants: ["C"], image: UIImage(named: "thumbnail")!)
 let listTemplateA = CPGridTemplate(title: "AA", gridButtons: [itemA, itemAA, itemAAA])
 */
