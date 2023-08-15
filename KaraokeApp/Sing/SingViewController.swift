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
        startButton.setTitle("Start", for: .normal)

        updateUI()
        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))
        displayLink.add(to: .current, forMode: .common)

        audioSystem.loadSong(songURL: currentSong.path)
        audioSystem.start()
    }

    deinit {
        audioSystem.stop()
    }

    @IBAction func startTapped(_ sender: Any) {
        if audioSystem.isPlaying() {
            displayLink.remove(from: .current, forMode: .common)
            startButton.setTitle("Start", for: .normal)
            audioSystem.finish()

            let sender: Song = currentSong
            self.performSegue(withIdentifier: "showMixer", sender: sender)
        } else {
            startButton.setTitle("Finish", for: .normal)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! MixerViewController
        let song = sender as! Song
        vc.currentSong = song
    }
}
