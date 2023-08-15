//
//  MixerAudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import SwitchboardSDK
import SwitchboardSuperpowered

class MixerAudioSystem: AudioSystem {
    let musicPlayer = SBAudioPlayerNode()
    let voicePlayer = SBAudioPlayerNode()
    let mixerNode = SBMixerNode()
    let offlineGraphRenderer = SBOfflineGraphRenderer()
    let musicGainNode = SBGainNode()
    let voiceGainNode = SBGainNode()
    let reverbNode = SBReverbNode()
    let autotuneNode = SBAutotuneNode()

    override init() {
        super.init()

        audioGraph.addNode(musicPlayer)
        audioGraph.addNode(voicePlayer)
        audioGraph.addNode(mixerNode)
        audioGraph.addNode(musicGainNode)
        audioGraph.addNode(voiceGainNode)
        audioGraph.addNode(reverbNode)
        audioGraph.addNode(autotuneNode)
        audioGraph.connect(musicPlayer, to: musicGainNode)
        audioGraph.connect(musicGainNode, to: mixerNode)
        audioGraph.connect(voicePlayer, to: voiceGainNode)
        audioGraph.connect(voiceGainNode, to: autotuneNode)
        audioGraph.connect(autotuneNode, to: reverbNode)
        audioGraph.connect(reverbNode, to: mixerNode)
        audioGraph.connect(mixerNode, to: audioGraph.outputNode)

        audioEngine.microphoneEnabled = false
    }

    func isPlaying() -> Bool {
        return musicPlayer.isPlaying
    }

    func renderMix() -> String {
        let sampleRate = max(musicPlayer.sourceSampleRate, voicePlayer.sourceSampleRate)
        musicPlayer.position = 0.0
        voicePlayer.position = 0.0
        musicPlayer.play()
        voicePlayer.play()
        offlineGraphRenderer.sampleRate = sampleRate
        offlineGraphRenderer.maxNumberOfSecondsToRender = musicPlayer.duration()
        offlineGraphRenderer.processGraph(audioGraph, withOutputFile: Config.mixedFilePath, withOutputFileCodec: Config.fileFormat)

        return Config.mixedFilePath
    }

    func play() {
        musicPlayer.play()
        voicePlayer.play()
    }

    func pause() {
        musicPlayer.pause()
        voicePlayer.pause()
    }

    func loadSong(songURL: String) {
        musicPlayer.load(songURL)
    }

    func loadRecording(recordingPath: String) {
        voicePlayer.load(recordingPath, withFormat: Config.fileFormat)
    }

    func getSongDurationInSeconds() -> Double {
        return musicPlayer.duration()
    }

    func getPositionInSeconds() -> Double {
        return musicPlayer.position
    }

    func setPositionInSeconds(position: Double) {
        musicPlayer.position = position
        if (voicePlayer.duration() > position) {
            voicePlayer.position = position
        }
    }

    func getProgress() -> Float {
        return Float(musicPlayer.position / musicPlayer.duration())
    }

    func setMusicVolume(volume: Int) {
        musicGainNode.gain = Float(volume) / 100.0
    }

    func setVoiceVolume(volume: Int) {
        voiceGainNode.gain = Float(volume) / 100.0
    }

    func enableReverb(enable: Bool) {
        reverbNode.isEnabled = enable
    }

    func enableAutotune(enable: Bool) {
        autotuneNode.isEnabled = enable
    }
}
