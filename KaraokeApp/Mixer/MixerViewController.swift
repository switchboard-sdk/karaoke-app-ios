//
//  MixerViewController.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import UIKit

class MixerViewController: UIViewController {

    var currentSong: Song!

    let audioSystem = MixerAudioSystem()

    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressSeekbar: UISlider!
    @IBOutlet weak var duration: UILabel!

    @IBOutlet weak var vocalSlider: UISlider!
    @IBOutlet weak var musicSlider: UISlider!

    @IBOutlet weak var reverbSwitch: UISwitch!
    @IBOutlet weak var compressorSwitch: UISwitch!
    @IBOutlet weak var avpcSwitch: UISwitch!

    @IBOutlet weak var loader: UIView!

    var displayLink: CADisplayLink!

    var wasPlaying: Bool = false

    override func viewDidLoad() {

        audioSystem.loadSong(songURL: currentSong.path)
        audioSystem.loadRecording(recordingPath: Config.recordingFilePath)
        songTitle.text = currentSong.displayName
        duration.text = "\(Int(audioSystem.getPositionInSeconds()) / 60)m \(Int(audioSystem.getPositionInSeconds()) % 60)s " +
        "/ \(currentSong.duration)"
        progressSeekbar.value = audioSystem.getProgress()
        progressSeekbar.setThumbImage(UIImage(), for: .normal)
        progressSeekbar.addTarget(self, action: #selector(progressChanged(slider:event:)), for: .valueChanged)

        vocalSlider.value = audioSystem.voiceGainNode.gain
        musicSlider.value = audioSystem.musicGainNode.gain
        reverbSwitch.isOn = audioSystem.reverbNode.isEnabled
        compressorSwitch.isOn = audioSystem.compressorNode.isEnabled
        avpcSwitch.isOn = audioSystem.avpcNode.isEnabled

        displayLink = CADisplayLink(target: self, selector: #selector(updateUI))

        audioSystem.start()
    }

    deinit {
        audioSystem.stop()
    }

    @objc func updateUI() {
        progressSeekbar.value = audioSystem.getProgress()
        duration.text = "\(Int(audioSystem.getPositionInSeconds()) / 60)m \(Int(audioSystem.getPositionInSeconds()) % 60)s " +
        "/ \(currentSong.duration)"
    }

    private func play() {
        displayLink.add(to: .current, forMode: .common)
        audioSystem.play()
        playButton.setTitle("Stop", for: .normal)
    }

    private func pause() {
        audioSystem.pause()
        displayLink.remove(from: .current, forMode: .common)
        playButton.setTitle("Play", for: .normal)
    }

    @IBAction func playTapped(_ sender: Any) {
        if audioSystem.isPlaying() {
            pause()
        } else {
            play()
        }
    }

    @objc func progressChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                wasPlaying = audioSystem.isPlaying()
                if wasPlaying {
                    pause()
                }
            case .ended:
                audioSystem.setPositionInSeconds(position: Double(progressSeekbar.value) * audioSystem.getSongDurationInSeconds())
                if wasPlaying {
                    play()
                }
            default:
                break
            }
        }
    }

    @IBAction func vocalVolumeChanged(_ sender: Any) {
        audioSystem.setVoiceVolume(volume: vocalSlider.value)
    }

    @IBAction func musicVolumeChanged(_ sender: Any) {
        audioSystem.setMusicVolume(volume: musicSlider.value)
    }

    @IBAction func reverbSwitched(_ sender: Any) {
        audioSystem.enableReverb(enable: reverbSwitch.isOn)
    }

    @IBAction func compressorSwitched(_ sender: Any) {
        audioSystem.enableCompressor(enable: compressorSwitch.isOn)
    }

    @IBAction func avpcSwitched(_ sender: Any) {
        audioSystem.enableAutotune(enable: avpcSwitch.isOn)
    }

    @IBAction func exportTapped(_ sender: Any) {
        loader.isHidden = false
        if audioSystem.isPlaying() {
            pause()
        }
        audioSystem.stop()

        DispatchQueue.global(qos: .default).async {
            let filePath = self.audioSystem.renderMix()

            DispatchQueue.main.async {
                self.loader.isHidden = true
                let fileURL = NSURL(fileURLWithPath: filePath)
                var filesToShare = [Any]()
                filesToShare.append(fileURL)
                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
                    self.audioSystem.voicePlayer.position = 0.0
                    self.audioSystem.musicPlayer.position = 0.0
                    self.audioSystem.pause()
                    self.audioSystem.start()
                }
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}
