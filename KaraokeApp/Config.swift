//
//  Config.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import Foundation

struct Config {
    static let clientID = "Synervoz"
    static let clientSecret = "KaraokeApp"
    static let superpoweredLicenseKey = "ExampleLicenseKey-WillExpire-OnNextUpdate"
    static var roundTripLatencySeconds = 0.0

    static var recordingFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("recording.wav").path
    }

    static var mixedFilePath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("mix.wav").path
    }
}
