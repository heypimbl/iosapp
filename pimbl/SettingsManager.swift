//
//  SettingsManager.swift
//  pimbl
//
//  Created by Macbook Pro on 12/15/25.
//

import Foundation

class SettingsManager: ObservableObject {
    @Published var serverURL: String {
        didSet {
            UserDefaults.standard.set(serverURL, forKey: "serverURL")
        }
    }

    init() {
        self.serverURL = UserDefaults.standard.string(forKey: "serverURL") ?? "https://pimbl.mou.fo/problem"
    }
}
