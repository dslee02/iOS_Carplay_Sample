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
        
        let tabTemplates = CPTabBarTemplate(templates: [audioListTemplete(), audioGridTemplete()])
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


extension CarPlaySceneDelegate {
    private func showNowPlayingTemplate(_ audioFile: AudioFile) {
        AudioManager.shared.stop()
        AudioManager.shared.play(audioFile)
        
        let nowPlayingTemplate = CPNowPlayingTemplate.shared
        nowPlayingTemplate.updateNowPlayingButtons(nowPlayingButtonTemplete())
        nowPlayingTemplate.isUpNextButtonEnabled = true
        interfaceController?.pushTemplate(nowPlayingTemplate, animated: true, completion: nil)
    }
    
}


// MARK: - Make Templete
extension CarPlaySceneDelegate {
    private func audioListTemplete() -> CPListTemplate {
        var listItems = [CPListItem]()
        
        AudioFileManager.shred.list.forEach { audioFile in
            let item = CPListItem(text: audioFile.name, detailText: audioFile.detailText, image: UIImage(named: audioFile.thumbnail))
            item.handler = { playlistItem, completion in
                self.showNowPlayingTemplate(audioFile)
                completion()
            }
            listItems.append(item)
        }
        
        let section = CPListSection(items: listItems)
        let template = CPListTemplate(title: "Audio List", sections: [section])
        template.tabImage = UIImage(systemName: "list.bullet")
        
        return template
    }
    
    private func audioGridTemplete() -> CPGridTemplate {
        var GridButtons = [CPGridButton]()
        
        AudioFileManager.shred.list.forEach { audioFile in
            let item = CPGridButton(titleVariants: [audioFile.name], image: UIImage(named: audioFile.thumbnail)!) { _ in
                self.showNowPlayingTemplate(audioFile)
            }
            GridButtons.append(item)
        }

        let template = CPGridTemplate(title: "Audio Grid", gridButtons: GridButtons)
        
        template.tabImage = UIImage(systemName: "rectangle.grid.3x2")
        
        return template
    }
    
    /// 최대 노출 갯수가 제한이 있는것으로 보임!? 현재 5개 가능
    private func nowPlayingButtonTemplete() -> [CPNowPlayingButton] {
        let defaultButton = CPNowPlayingButton() { _ in
            print("defaultButton")
        }
        
        let moreButton = CPNowPlayingMoreButton() { _ in
            print("moreButton")
        }
        
        let imageButton = CPNowPlayingImageButton(image: UIImage(named: "thumbnail")!) { _ in
            print("imageButton")
        }
        
        let addToLibraryButton = CPNowPlayingAddToLibraryButton() { _ in
            print("addToLibraryButton")
        }
        
        let repeatButton = CPNowPlayingRepeatButton() { _ in
            print("repeatButton")
        }
        
        let playbackRateButton = CPNowPlayingPlaybackRateButton() { _ in
            print("playbackRateButton")
        }
        
        let shuffleButton = CPNowPlayingShuffleButton() { _ in
            print("shuffleButton")
        }
        
        return [imageButton, addToLibraryButton, repeatButton, playbackRateButton, shuffleButton,]
    }
}
/**
 let itemA = CPGridButton(titleVariants: ["A"], image: UIImage(named: "thumbnail")!)
 let itemAA = CPGridButton(titleVariants: ["B"], image: UIImage(named: "thumbnail")!)
 let itemAAA = CPGridButton(titleVariants: ["C"], image: UIImage(named: "thumbnail")!)
 let listTemplateA = CPGridTemplate(title: "AA", gridButtons: [itemA, itemAA, itemAAA])
 */
