//
//  RemoteConfigService.swift
//  MemeGenerator
//
//  Created by Emil Maharramov on 03.02.26.
//

import FirebaseRemoteConfig

final class RemoteConfigService {

    static let shared = RemoteConfigService()
    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings

        remoteConfig.setDefaults([
            "component_visibility": true as NSObject
        ])
    }

    func fetch() {
        remoteConfig.fetchAndActivate { status, error in
            print("Remote config fetched")
        }
    }

    var componentVisibility: Bool {
        remoteConfig["component_visibility"].boolValue
    }
}
