//
//  AudioListViewController.swift
//  Sapmle_MP3
//
//  Created by dasol lee on 2023/02/01.
//

import UIKit

class AudioListViewController: UIViewController {
    @IBOutlet weak var tablewView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablewView.reloadData()
    }
}

extension AudioListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioFileManager.shred.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: "myCellType", for: indexPath)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "myCellType")
        }
        
        guard indexPath.row < AudioFileManager.shred.list.count else { return cell }
        cell.textLabel?.text = AudioFileManager.shred.list[indexPath.row].name
        return cell
    }
}

extension AudioListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let audio = AudioFileManager.shred.list[indexPath.row]
        presentModal(audio)
    }
    
    func presentModal(_ audio: AudioFile) {
        print("didSelectRowAt: \(audio.name)")
        
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AudioPlayViewController") as? AudioPlayViewController else { return }
        vc.audio = audio
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        
        /// iOS 15 
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(nav, animated: true)
    }
}
