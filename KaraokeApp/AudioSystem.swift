//
//  AudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import SwitchboardSDK

class AudioSystem {
    let audioEngine = SBAudioEngine()
    let audioGraph = SBAudioGraph()

    func start() {
        audioEngine.start(audioGraph)
    }

    func stop() {
        audioEngine.stop()
    }
}
