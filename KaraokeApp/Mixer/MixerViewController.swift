//
//  MixerViewController.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import UIKit

class MixerViewController: UIViewController {

    let audioSystem = MixerAudioSystem()

    override func viewDidLoad() {

        audioSystem.start()
    }

    deinit {
        audioSystem.stop()
    }

}
