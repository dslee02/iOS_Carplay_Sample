//
//  FileManager.swift
//  Sample_AudioApp
//
//  Created by dasol lee on 2023/02/03.
//

import Foundation

struct AudioFile: Equatable {
    let name: String
    let detailText: String
    let path: URL
    let thumbnail: String
    
    init(name: String, path: URL) {
        self.name = name
        self.detailText = "detail Text"
        self.path = path
        self.thumbnail = "thumbnail"
    }
}

class AudioFileManager {
    public static let shred = AudioFileManager()
    private let fileManager = FileManager.default
    public var list: [AudioFile] = [AudioFile]()
    
    init() {
        loadFileList()
    }
    
    private func loadFileList() {
        for i in 1...80 {
            guard let audioFile = loadAudioFile(String(format: "%02d", i)) else { return }
            list.append(audioFile)
        }
    }
    
    private func loadAudioFile(_ fileIndex: String) -> AudioFile? {
        let fileName = "EP106_\(fileIndex)"
        guard let filePath = Bundle.main.path(forResource: fileName, ofType: "mp3") else { return nil }
        guard let fileURL = URL(string:filePath) else { return nil }
        return AudioFile(name: fileName, path: fileURL)
    }
    
    public func forwardAudioFile(_ audioFile: AudioFile?) -> AudioFile? {
        guard let audioFile = audioFile else { return nil }
        if let index = list.firstIndex(of: audioFile), index + 1 < list.count {
            let nextAudio = list[index+1]
            return nextAudio
        }
        return nil
    }
    
    public func backwardAudioFile(_ audioFile: AudioFile?) -> AudioFile? {
        guard let audioFile = audioFile else { return nil }
        
        if let index = list.firstIndex(of: audioFile), index - 1 < list.count, index - 1 >= 0 {
            let nextAudio = list[index-1]
            return nextAudio
        }
        return nil
    }
}
