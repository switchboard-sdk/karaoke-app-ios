//
//  AudioSystem.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import SwitchboardSDK

class AudioSystem {
    var engineID: String = ""

    func start() {
        let result = Switchboard.callAction(withObject: engineID, actionName: "start", params: nil)
        guard result.success else {
            fatalError("Failed to start engine: \(result.error!)")
        }
    }

    func stop() {
        let result = Switchboard.callAction(withObject: engineID, actionName: "stop", params: nil)
        guard result.success else {
            fatalError("Failed to stop engine: \(result.error!)")
        }
    }
}
