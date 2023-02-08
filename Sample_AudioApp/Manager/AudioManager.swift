//
//  AudioManager.swift
//  Sample_AudioApp
//
//  Created by dasol lee on 2023/02/08.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

enum AudioPlayStatus {
    case playing
    case pause
}

protocol AudioManagerDelegate: NSObjectProtocol {
    func updatePlayStatus(_ status: AudioPlayStatus)
    func updatePlayFile(_ audio: AudioFile?)
}

class AudioManager: NSObject {
    public static let shared = AudioManager()
    public weak var delegate: AudioManagerDelegate?
    public var audio: AudioFile?
    private var audioSessionHandler: [Any?] = [Any?]()
    private var audioPlayer = AVAudioPlayer()
    private var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                delegate?.updatePlayStatus(.pause)
            } else {
                delegate?.updatePlayStatus(.playing)
            }
        }
    }
    
    private var isPause: Bool = false {
        didSet {
            if isPause == true {
                audioPlayer.pause()
            } else {
                audioPlayer.play()
            }
        }
    }
    
    override init() {
        super.init()
        self.setupRemoteTransportControls()
    }
    
    deinit {
        removeRemoteTransportControls()
    }
    
    public func play(_ audio: AudioFile? = nil) {
        if let audio = audio {
            self.audio = audio
        }

        if isPause == true {
            isPause = false
            isPlaying = true
        } else if isPlaying == true {
            isPause = true
            isPlaying = false
        } else {
            isPlaying = true
            playAudio(self.audio?.path)
        }
    }
    
    public func backward() {
        audio = AudioFileManager.shred.backwardAudioFile(audio)
        playAudio(audio?.path)
    }
    
    public func forward() {
        audio = AudioFileManager.shred.forwardAudioFile(audio)
        playAudio(audio?.path)
    }
    
    private func playAudio(_ audioUrl: URL?) {
        guard let audioUrl = audioUrl else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer.delegate = self
        } catch let e {
            print(e)
        }
        audioPlayer.play()
        remoteCommandInfoCenterSetting()
        delegate?.updatePlayFile(audio)
        print(String(describing: audio?.name))
    }
}

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        forward()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur \(String(describing: error?.localizedDescription))")
    }
}

extension AudioManager {
    private func setupRemoteTransportControls() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        audioSessionHandler.append(commandCenter.playCommand.addTarget { [unowned self] event in
            self.play()
            return .success
        })
        audioSessionHandler.append(commandCenter.pauseCommand.addTarget { [unowned self] event in
            self.play()
            return .success
        })
        audioSessionHandler.append(commandCenter.stopCommand.addTarget { [unowned self] event in
            self.play()
            return .success
        })
        audioSessionHandler.append(commandCenter.nextTrackCommand.addTarget { [unowned self] event in
            self.forward()
            return .success
        })
        audioSessionHandler.append(commandCenter.previousTrackCommand.addTarget { [unowned self] event in
            self.backward()
            return .success
        })
    }
    
    private func removeRemoteTransportControls() {
        audioSessionHandler.forEach { value in
            if let value = value as? MPRemoteCommand {
                value.removeTarget(value)
            }
        }
    }
    
    private func remoteCommandInfoCenterSetting() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Audio"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "Artist"
        
        if let title = audio?.name {
            nowPlayingInfo[MPMediaItemPropertyTitle] = title
        }
        
        if let albumCoverPage = UIImage(named: "thumbnail") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: albumCoverPage.size, requestHandler: { size in
                return albumCoverPage
            })
        }
        
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration // 콘텐츠 총 길이
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate // 콘텐츠 재생 시간에 따른 progressBar 초기화
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime // 콘텐츠 현재 재생시간
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
