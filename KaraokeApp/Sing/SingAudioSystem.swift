//
//  SingAudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import AVFoundation
import SwitchboardSDK

class SingAudioSystem: AudioSystem {
    private static let graphJSON = """
    {
        "type": "Realtime",
        "config": {
            "microphoneEnabled": true,
            "graph": {
                "nodes": [
                    {
                        "id": "subgraphNode",
                        "type": "SubgraphProcessor",
                        "config": {
                            "graph": {
                                "nodes": [
                                    {
                                        "id": "multiChannelToMonoNode",
                                        "type": "MultiChannelToMono"
                                    },
                                    {
                                        "id": "busSplitterNode",
                                        "type": "BusSplitter"
                                    },
                                    {
                                        "id": "vuMeterNode",
                                        "type": "Switchboard.VUMeter"
                                    },
                                    {
                                        "id": "recorderNode",
                                        "type": "Recorder"
                                    },
                                    {
                                        "id": "audioPlayerNode",
                                        "type": "AudioPlayer"
                                    }
                                ],
                                "connections": [
                                    {
                                        "sourceNode": "inputNode",
                                        "destinationNode": "multiChannelToMonoNode"
                                    },
                                    {
                                        "sourceNode": "multiChannelToMonoNode",
                                        "destinationNode": "busSplitterNode"
                                    },
                                    {
                                        "sourceNode": "busSplitterNode",
                                        "destinationNode": "vuMeterNode"
                                    },
                                    {
                                        "sourceNode": "busSplitterNode",
                                        "destinationNode": "recorderNode"
                                    },
                                    {
                                        "sourceNode": "audioPlayerNode",
                                        "destinationNode": "outputNode"
                                    }
                                ]
                            }
                        }
                    }
                ],
                "connections": [
                    {
                        "sourceNode": "inputNode",
                        "destinationNode": "subgraphNode"
                    },
                    {
                        "sourceNode": "subgraphNode",
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
            fatalError("Failed to create Sing engine: \(result.error!)")
        }
        engineID = result.value! as String
    }

    func playAndRecord() {
        Switchboard.callAction(withObject: "audioPlayerNode", actionName: "play", params: nil)
        Switchboard.callAction(withObject: "recorderNode", actionName: "start", params: nil)
    }

    func loadSong(songURL: String) {
        Switchboard.callAction(withObject: "audioPlayerNode", actionName: "load", params: ["audioFilePath": songURL])
    }

    func getSongDurationInSeconds() -> Double {
        let result = Switchboard.getValueForKey("duration", object: "audioPlayerNode")
        return (result.value as? NSNumber)?.doubleValue ?? 0.0
    }

    func getPositionInSeconds() -> Double {
        let result = Switchboard.getValueForKey("position", object: "audioPlayerNode")
        return (result.value as? NSNumber)?.doubleValue ?? 0.0
    }

    func getProgress() -> Float {
        let duration = getSongDurationInSeconds()
        guard duration > 0 else { return 0 }
        return Float(getPositionInSeconds() / duration)
    }

    func isPlaying() -> Bool {
        let result = Switchboard.getValueForKey("isPlaying", object: "audioPlayerNode")
        return result.value as? Bool ?? false
    }

    var vuMeterLevel: Float {
        let result = Switchboard.getValueForKey("level", object: "vuMeterNode")
        return (result.value as? NSNumber)?.floatValue ?? 0.0
    }

    var vuMeterPeak: Float {
        let result = Switchboard.getValueForKey("peak", object: "vuMeterNode")
        return (result.value as? NSNumber)?.floatValue ?? 0.0
    }

    func finish() {
        calculateRoundTripLatency()
        stop()
        Switchboard.callAction(withObject: "audioPlayerNode", actionName: "stop", params: nil)
        Switchboard.setValue(Config.recordingFilePath, forKey: "outputFilePath", onObject: "recorderNode")
        Switchboard.callAction(withObject: "recorderNode", actionName: "stop", params: nil)
    }

    func calculateRoundTripLatency() {
        let session = AVAudioSession.sharedInstance()
        let inputLatency = session.inputLatency
        let outputLatency = session.outputLatency
        let ioBufferDuration = session.ioBufferDuration

        if inputLatency > 0 && outputLatency > 0 && ioBufferDuration > 0 {
            Config.roundTripLatencySeconds = inputLatency + outputLatency + ioBufferDuration * 2
            SBLogger.info("roundTripLatencySeconds: \(Config.roundTripLatencySeconds)")
        }
    }
}
