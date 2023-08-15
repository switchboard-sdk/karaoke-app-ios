//
//  SingAudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import SwitchboardSDK
import SwitchboardSuperpowered

class SingAudioSystem: AudioSystem {
    let internalAudioGraph = SBAudioGraph()
    let subgraphNode = SBSubgraphProcessorNode()
    let audioPlayerNode = SBAudioPlayerNode()
    let recorderNode = SBRecorderNode()
    let splitterNode = SBBusSplitterNode()
    let multiChannelToMonoNode = SBMultiChannelToMonoNode()
    let vuMeterNode = SBVUMeterNode()

    override init() {
        super.init()

        vuMeterNode.smoothingDurationMs = 100.0
        internalAudioGraph.addNode(audioPlayerNode)
        internalAudioGraph.addNode(recorderNode)
        internalAudioGraph.addNode(splitterNode)
        internalAudioGraph.addNode(multiChannelToMonoNode)
        internalAudioGraph.addNode(vuMeterNode)
        internalAudioGraph.connect(internalAudioGraph.inputNode, to: splitterNode)
        internalAudioGraph.connect(splitterNode, to: recorderNode)
        internalAudioGraph.connect(splitterNode, to: multiChannelToMonoNode)
        internalAudioGraph.connect(multiChannelToMonoNode, to: vuMeterNode)
        internalAudioGraph.connect(audioPlayerNode, to: internalAudioGraph.outputNode)
        subgraphNode.audioGraph = internalAudioGraph

        audioGraph.addNode(subgraphNode)
        audioGraph.connect(audioGraph.inputNode, to: subgraphNode)
        audioGraph.connect(subgraphNode, to: audioGraph.outputNode)

        audioEngine.microphoneEnabled = true
    }

    override func start() {
        internalAudioGraph.start()
        super.start()
    }

    func playAndRecord() {
        audioPlayerNode.play()
        recorderNode.start()
    }

    func loadSong(songURL: String) {
        audioPlayerNode.load(songURL)
    }

    func getSongDurationInSeconds() -> Double {
        return audioPlayerNode.duration()
    }

    func getPositionInSeconds() -> Double {
        return audioPlayerNode.position
    }

    func getProgress() -> Float {
        return Float(audioPlayerNode.position / audioPlayerNode.duration())
    }

    func isPlaying() -> Bool {
        return audioPlayerNode.isPlaying
    }

    func finish() {
        super.stop()
        internalAudioGraph.stop()
        audioPlayerNode.stop()
        recorderNode.stop(Config.recordingFilePath, withFormat: Config.fileFormat)
    }
}
