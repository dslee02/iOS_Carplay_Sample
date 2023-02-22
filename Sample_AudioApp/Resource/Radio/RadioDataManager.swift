//
//  RadioDataManager.swift
//  CarPlayTutorial
//
//  Created by Jordan Montel on 15/07/2021.
//

import Foundation

class RadioDataManager {
    static let shared = RadioDataManager()
    var radios: [Radio]

    init() {
        self.radios = [Radio]()

        do {
            let data = try Data(contentsOf: Bundle.main.url(forResource: "radios", withExtension: "json")!)
            self.radios = try JSONDecoder().decode([Radio].self, from: data)
        } catch {
            print("RadioDataManager init get radios.json file load error \(error)")
        }
    }
}
