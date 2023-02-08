//
//  AudioPlayViewController.swift
//  Sapmle_MP3
//
//  Created by dasol lee on 2023/02/01.
//

import UIKit
import AVFoundation
import MediaPlayer

class AudioPlayViewController: UIViewController {
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    public var audio: AudioFile? {
        didSet {
            self.title = audio?.name
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioManager.shared.delegate = self
        AudioManager.shared.play(audio)
    }
   
    @IBAction func didTouchPlayButton(_ sender: UIButton) {
        AudioManager.shared.play()
    }
    
    @IBAction func didTouchForwardButton(_ sender: UIButton) {
        AudioManager.shared.forward()
    }
    
    @IBAction func didTouchBackwardButton(_ sender: UIButton) {
        AudioManager.shared.backward()
    }
}

extension AudioPlayViewController: AudioManagerDelegate {
    func updatePlayStatus(_ status: AudioPlayStatus) {
        switch status {
        case .playing: playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        case .pause: playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
}


