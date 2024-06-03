//
//  TimeManager.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import Combine

class TimeManager: ObservableObject {
    @Published var currentDate: Date = Date()
    
    var timer: AnyCancellable?
    
    init() {
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] date in self?.currentDate = date })
    }
}
