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

enum AudioPlayMedia {
    case audio
    case radio
}

protocol AudioManagerDelegate: NSObjectProtocol {
    func updatePlayStatus(_ status: AudioPlayStatus)
    func updatePlayFile(_ audio: AudioFile?)
}

class AudioManager: NSObject {
    public static let shared = AudioManager()
    public weak var delegate: AudioManagerDelegate?
    public var currentMedia: AudioPlayMedia = .audio
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
    
    
    // MARK: - Radio
    public func playRadio(_ radio: Radio, _ data: Data) {
        currentMedia = .radio

        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer.delegate = self
            audioPlayer.play()
        } catch {
            print(error)
        }
        
        remoteCommandInfoCenterSetting(radio)
        print(String(describing: radio.title))
    }
    
    
    // MARK: - Audio
    public func play(_ audio: AudioFile? = nil) {
        currentMedia = .audio
        
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
    
    public func stop() {
        audioPlayer.pause()
        audioPlayer.stop()
    }
    
    public func backward() {
        guard currentMedia == .audio else { return }
        
        audio = AudioFileManager.shred.backwardAudioFile(audio)
        playAudio(audio?.path)
    }
    
    public func forward() {
        guard currentMedia == .audio else { return }
        
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
            self.stop()
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
        var nowPlayingInfo: [String: Any] = [MPMediaItemPropertyTitle: audio?.name ?? "Audio",
                                            MPMediaItemPropertyArtist: "Artist",
                                  MPMediaItemPropertyPlaybackDuration: audioPlayer.duration,
                                 MPNowPlayingInfoPropertyPlaybackRate: audioPlayer.rate,
                          MPNowPlayingInfoPropertyElapsedPlaybackTime: audioPlayer.currentTime
        ]
        
        if let albumCoverPage = UIImage(named: "thumbnail") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: albumCoverPage.size, requestHandler: { size in
                return albumCoverPage
            })
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func remoteCommandInfoCenterSetting(_ radio: Radio) {
        var nowPlayingInfo: [String: Any] = [MPMediaItemPropertyTitle: radio.title ,
                                            MPMediaItemPropertyArtist: radio.subtitle,
                                  MPMediaItemPropertyPlaybackDuration: audioPlayer.duration,
                                 MPNowPlayingInfoPropertyPlaybackRate: audioPlayer.rate,
                          MPNowPlayingInfoPropertyElapsedPlaybackTime: audioPlayer.currentTime
        ]
        
        if let albumCoverPage = UIImage(named: radio.imageUrl) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: albumCoverPage.size, requestHandler: { size in
                return albumCoverPage
            })
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
