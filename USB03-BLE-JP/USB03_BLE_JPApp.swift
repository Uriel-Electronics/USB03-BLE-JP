//
//  USB03_BLE_JPApp.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI

@main
struct USB03_BLE_JPApp: App {
    var timerManager = TimeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
        }
    }
}
