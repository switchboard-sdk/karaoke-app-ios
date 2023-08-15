//
//  SongListAudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import SwitchboardSDK

class SongListAudioSystem: AudioSystem {
    let audioPlayerNode = SBAudioPlayerNode()

    override init() {
        super.init()
        audioGraph.addNode(audioPlayerNode)
        audioGraph.connect(audioPlayerNode, to: audioGraph.outputNode)
    }

    func play() {
        audioPlayerNode.play()
    }

    func pause() {
        audioPlayerNode.pause()
    }

    func loadSong(songURL: String) {
        audioPlayerNode.load(songURL)
    }
}
