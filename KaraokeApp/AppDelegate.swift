//
//  AppDelegate.swift
//  KaraokeApp
//
//  Created by Iván Nádor on 2023. 08. 14..
//

import UIKit
import SwitchboardSDK
import SwitchboardSuperpowered

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        var extensionsConfig: [String: Any] = [:]
        SBSuperpoweredExtension.loadExtension()
        extensionsConfig["Superpowered"] = [
            "superpoweredLicenseKey": Config.superpoweredLicenseKey,
        ]

        let initConfig: [String: Any] = [
            "appID": Config.clientID,
            "appSecret": Config.clientSecret,
            "extensions": extensionsConfig,
        ]
        let result = Switchboard.initialize(withConfig: initConfig)
        guard result.success else {
            fatalError("Switchboard SDK initialization failed.")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        .portrait
    }
}
