//
//  SongListAudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import SwitchboardSDK

class SongListAudioSystem: AudioSystem {
    private static let graphJSON = """
    {
        "type": "Realtime",
        "config": {
            "graph": {
                "nodes": [
                    {
                        "id": "audioPlayerNode",
                        "type": "AudioPlayer"
                    }
                ],
                "connections": [
                    {
                        "sourceNode": "audioPlayerNode",
                        "destinationNode": "outputNode"
                    }
                ]
            }
        }
    }
    """

    override init() {
        super.init()
        let result = Switchboard.createEngine(withJSON: Self.graphJSON)
        guard result.success else {
            fatalError("Failed to create SongList engine: \(result.error!)")
        }
        engineID = result.value! as String
    }

    var isPlaying: Bool {
        let result = Switchboard.getValueForKey("isPlaying", object: "audioPlayerNode")
        return result.value as? Bool ?? false
    }

    func play() {
        Switchboard.callAction(withObject: "audioPlayerNode", actionName: "play", params: nil)
    }

    func pause() {
        Switchboard.callAction(withObject: "audioPlayerNode", actionName: "pause", params: nil)
    }

    func loadSong(songURL: String) {
        Switchboard.callAction(withObject: "audioPlayerNode", actionName: "load", params: ["audioFilePath": songURL])
    }
}
