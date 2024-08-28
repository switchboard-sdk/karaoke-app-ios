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
        calculateRoundTripLatency()
        super.stop()
        internalAudioGraph.stop()
        audioPlayerNode.stop()
        recorderNode.stop(Config.recordingFilePath, withFormat: Config.fileFormat)
    }
    
    func calculateRoundTripLatency() {
        let inputLatency = audioEngine.lastAudioSessionState?.inputLatency ?? -1.0
        let outputLatency = audioEngine.lastAudioSessionState?.outputLatency ?? -1.0
        let ioBufferDurationValue = audioEngine.lastAudioSessionState?.IOBufferDuration ?? -1.0

        if inputLatency > 0 && outputLatency > 0 && ioBufferDurationValue > 0 {
            // the multiply by two factor accounts for both input and output buffer latencies
            // the ioBufferDurationValue defines how much audio data is processed in each cycle for both input and output.
            // docs: https://developer.apple.com/documentation/avfaudio/avaudiosession/1616589-setpreferrediobufferduration?language=objc
            Config.roundTripLatencySeconds = inputLatency + outputLatency + ioBufferDurationValue * 2
            SBLogger.info("roundTripLatencySeconds: \(Config.roundTripLatencySeconds)")
        }
    }
}
