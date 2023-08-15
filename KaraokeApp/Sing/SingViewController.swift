//
//  SingViewController.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import UIKit

class SingViewController: UIViewController {

    var currentSong: Song!

    let audioSystem = SingAudioSystem()

    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var durationLabel: UILabel!

    @IBOutlet weak var rms: UIProgressView!
    @IBOutlet weak var peak: UIProgressView!

    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var lyrics: UILabel!

    var displayLink: CADisplayLink!

    override func viewDidLoad() {
        songTitle.text = currentSong.displayName
        lyrics.text = currentSong.lyrics

        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))

        audioSystem.start()
    }

    deinit {
        audioSystem.stop()
    }

    @IBAction func startTapped(_ sender: Any) {
        if audioSystem.isPlaying() {
            displayLink.remove(from: .current, forMode: .common)
        } else {
            displayLink.add(to: .current, forMode: .common)
            audioSystem.playAndRecord()
        }
    }

    @objc func updateUI() {
        progress.progress = audioSystem.getProgress()
        durationLabel.text = "\(Int(audioSystem.getPositionInSeconds()) / 60)m \(Int(audioSystem.getPositionInSeconds()) % 60)s " +
        "/ \(currentSong.duration)"

        rms.progress = audioSystem.vuMeterNode.level
        peak.progress = audioSystem.vuMeterNode.peak
    }
    
}
