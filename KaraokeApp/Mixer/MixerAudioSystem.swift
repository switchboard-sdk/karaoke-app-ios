//
//  MixerAudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import AVFoundation
import SwitchboardSDK

class MixerAudioSystem: AudioSystem {
    private static let graphJSON = """
    {
        "type": "Realtime",
        "config": {
            "graph": {
                "nodes": [
                    {
                        "id": "musicPlayerNode",
                        "type": "AudioPlayer"
                    },
                    {
                        "id": "voicePlayerNode",
                        "type": "AudioPlayer"
                    },
                    {
                        "id": "musicGainNode",
                        "type": "Switchboard.Gain"
                    },
                    {
                        "id": "voiceGainNode",
                        "type": "Switchboard.Gain"
                    },
                    {
                        "id": "avpcNode",
                        "type": "Superpowered.AutomaticVocalPitchCorrection",
                        "config": { "enabled": false }
                    },
                    {
                        "id": "compressorNode",
                        "type": "Superpowered.Compressor",
                        "config": { "enabled": false }
                    },
                    {
                        "id": "reverbNode",
                        "type": "Superpowered.Reverb",
                        "config": { "enabled": false }
                    },
                    {
                        "id": "mixerNode",
                        "type": "Mixer"
                    }
                ],
                "connections": [
                    {
                        "sourceNode": "musicPlayerNode",
                        "destinationNode": "musicGainNode"
                    },
                    {
                        "sourceNode": "musicGainNode",
                        "destinationNode": "mixerNode"
                    },
                    {
                        "sourceNode": "voicePlayerNode",
                        "destinationNode": "voiceGainNode"
                    },
                    {
                        "sourceNode": "voiceGainNode",
                        "destinationNode": "avpcNode"
                    },
                    {
                        "sourceNode": "avpcNode",
                        "destinationNode": "compressorNode"
                    },
                    {
                        "sourceNode": "compressorNode",
                        "destinationNode": "reverbNode"
                    },
                    {
                        "sourceNode": "reverbNode",
                        "destinationNode": "mixerNode"
                    },
                    {
                        "sourceNode": "mixerNode",
                        "destinationNode": "outputNode"
                    }
                ]
            }
        }
    }
    """

    private var songURL: String = ""
    private var recordingPath: String = ""

    override init() {
        super.init()
        let result = Switchboard.createEngine(withJSON: Self.graphJSON)
        guard result.success else {
            fatalError("Failed to create Mixer engine: \(result.error!)")
        }
        engineID = result.value! as String
    }

    var musicGain: Float {
        let result = Switchboard.getValueForKey("gain", object: "musicGainNode")
        return (result.value as? NSNumber)?.floatValue ?? 1.0
    }

    var voiceGain: Float {
        let result = Switchboard.getValueForKey("gain", object: "voiceGainNode")
        return (result.value as? NSNumber)?.floatValue ?? 1.0
    }

    var isReverbEnabled: Bool {
        let result = Switchboard.getValueForKey("enabled", object: "reverbNode")
        return result.value as? Bool ?? false
    }

    var isCompressorEnabled: Bool {
        let result = Switchboard.getValueForKey("enabled", object: "compressorNode")
        return result.value as? Bool ?? false
    }

    var isAVPCEnabled: Bool {
        let result = Switchboard.getValueForKey("enabled", object: "avpcNode")
        return result.value as? Bool ?? false
    }

    func isPlaying() -> Bool {
        let result = Switchboard.getValueForKey("isPlaying", object: "musicPlayerNode")
        return result.value as? Bool ?? false
    }

    func play() {
        Switchboard.callAction(withObject: "musicPlayerNode", actionName: "play", params: nil)
        Switchboard.callAction(withObject: "voicePlayerNode", actionName: "play", params: nil)
    }

    func pause() {
        Switchboard.callAction(withObject: "musicPlayerNode", actionName: "pause", params: nil)
        Switchboard.callAction(withObject: "voicePlayerNode", actionName: "pause", params: nil)
    }

    func loadSong(songURL: String) {
        self.songURL = songURL
        Switchboard.callAction(withObject: "musicPlayerNode", actionName: "load", params: ["audioFilePath": songURL])
    }

    func loadRecording(recordingPath: String) {
        self.recordingPath = recordingPath
        Switchboard.callAction(withObject: "voicePlayerNode", actionName: "load", params: ["audioFilePath": recordingPath, "codec": "wav"])
    }

    func setRecordingOffset(offsetInSeconds: Double) {
        Switchboard.setValue(offsetInSeconds, forKey: "position", onObject: "voicePlayerNode")
    }

    func getSongDurationInSeconds() -> Double {
        let result = Switchboard.getValueForKey("duration", object: "musicPlayerNode")
        return (result.value as? NSNumber)?.doubleValue ?? 0.0
    }

    func getPositionInSeconds() -> Double {
        let result = Switchboard.getValueForKey("position", object: "musicPlayerNode")
        return (result.value as? NSNumber)?.doubleValue ?? 0.0
    }

    func setPositionInSeconds(position: Double) {
        Switchboard.setValue(position, forKey: "position", onObject: "musicPlayerNode")
        let voiceDuration: Double = {
            let result = Switchboard.getValueForKey("duration", object: "voicePlayerNode")
            return (result.value as? NSNumber)?.doubleValue ?? 0.0
        }()
        if voiceDuration > position {
            Switchboard.setValue(position, forKey: "position", onObject: "voicePlayerNode")
        }
    }

    func getProgress() -> Float {
        let duration = getSongDurationInSeconds()
        guard duration > 0 else { return 0 }
        return Float(getPositionInSeconds() / duration)
    }

    func setMusicVolume(volume: Float) {
        Switchboard.setValue(volume, forKey: "gain", onObject: "musicGainNode")
    }

    func setVoiceVolume(volume: Float) {
        Switchboard.setValue(volume, forKey: "gain", onObject: "voiceGainNode")
    }

    func enableReverb(enable: Bool) {
        Switchboard.setValue(enable, forKey: "enabled", onObject: "reverbNode")
    }

    func enableCompressor(enable: Bool) {
        Switchboard.setValue(enable, forKey: "enabled", onObject: "compressorNode")
    }

    func enableAutomaticVocalPitchCorrection(enable: Bool) {
        Switchboard.setValue(enable, forKey: "enabled", onObject: "avpcNode")
    }

    func resetPlayerPositions() {
        Switchboard.setValue(0.0, forKey: "position", onObject: "musicPlayerNode")
        Switchboard.setValue(0.0, forKey: "position", onObject: "voicePlayerNode")
    }

    func renderMix() -> String {
        let duration = getSongDurationInSeconds()
        let sampleRate = UInt(AVAudioSession.sharedInstance().sampleRate)

        let currentMusicGain = musicGain
        let currentVoiceGain = voiceGain
        let currentReverbEnabled = isReverbEnabled
        let currentCompressorEnabled = isCompressorEnabled
        let currentAVPCEnabled = isAVPCEnabled

        let offlineJSON = """
        {
            "type": "Offline",
            "config": {
                "sampleRate": \(sampleRate),
                "maxNumberOfSecondsToRender": \(duration),
                "outputFiles": [
                    {
                        "filePath": "\(Config.mixedFilePath)",
                        "codec": "wav",
                        "numberOfChannels": 2
                    }
                ],
                "graph": {
                    "nodes": [
                        {
                            "id": "offlineMusicPlayer",
                            "type": "AudioPlayer",
                            "config": { "audioFilePath": "\(songURL)" }
                        },
                        {
                            "id": "offlineVoicePlayer",
                            "type": "AudioPlayer",
                            "config": { "audioFilePath": "\(recordingPath)" }
                        },
                        { "id": "offlineMusicGain", "type": "Switchboard.Gain" },
                        { "id": "offlineVoiceGain", "type": "Switchboard.Gain" },
                        {
                            "id": "offlineAVPC",
                            "type": "Superpowered.AutomaticVocalPitchCorrection"
                        },
                        { "id": "offlineCompressor", "type": "Superpowered.Compressor" },
                        { "id": "offlineReverb", "type": "Superpowered.Reverb" },
                        { "id": "offlineMixer", "type": "Mixer" }
                    ],
                    "connections": [
                        { "sourceNode": "offlineMusicPlayer", "destinationNode": "offlineMusicGain" },
                        { "sourceNode": "offlineMusicGain", "destinationNode": "offlineMixer" },
                        { "sourceNode": "offlineVoicePlayer", "destinationNode": "offlineVoiceGain" },
                        { "sourceNode": "offlineVoiceGain", "destinationNode": "offlineAVPC" },
                        { "sourceNode": "offlineAVPC", "destinationNode": "offlineCompressor" },
                        { "sourceNode": "offlineCompressor", "destinationNode": "offlineReverb" },
                        { "sourceNode": "offlineReverb", "destinationNode": "offlineMixer" },
                        { "sourceNode": "offlineMixer", "destinationNode": "outputNode" }
                    ]
                }
            }
        }
        """

        let createResult = Switchboard.createEngine(withJSON: offlineJSON)
        guard createResult.success else {
            fatalError("Failed to create offline engine: \(createResult.error!)")
        }
        let offlineEngineID = createResult.value! as String

        Switchboard.setValue(currentMusicGain, forKey: "gain", onObject: "offlineMusicGain")
        Switchboard.setValue(currentVoiceGain, forKey: "gain", onObject: "offlineVoiceGain")
        Switchboard.setValue(currentReverbEnabled, forKey: "enabled", onObject: "offlineReverb")
        Switchboard.setValue(currentCompressorEnabled, forKey: "enabled", onObject: "offlineCompressor")
        Switchboard.setValue(currentAVPCEnabled, forKey: "enabled", onObject: "offlineAVPC")

        if Config.roundTripLatencySeconds > 0 {
            Switchboard.setValue(Config.roundTripLatencySeconds, forKey: "position", onObject: "offlineVoicePlayer")
        }

        Switchboard.callAction(withObject: offlineEngineID, actionName: "process", params: nil)
        Switchboard.destroyEngine(withObjectID: offlineEngineID)

        return Config.mixedFilePath
    }
}
