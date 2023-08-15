//
//  Config.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import Foundation
import SwitchboardSDK

struct Config {
    static let clientID = "Synervoz"
    static let clientSecret = "KaraokeApp"
    static let superpoweredLicenseKey = "ExampleLicenseKey-WillExpire-OnNextUpdate"

    static var recordingFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].absoluteString + "recording.wav"
    }

    static var mixedFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].absoluteString + "mix.wav"
    }

    static let fileFormat: SBCodec = .wav
}
