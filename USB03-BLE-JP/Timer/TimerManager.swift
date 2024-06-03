//
//  TimerManager.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import UserNotifications

class TimerViewModel: ObservableObject {
    
    @Published var remainingSeconds = 3600
    var timer: Timer?
    let defaults = UserDefaults.standard
    @Published var timerIsActive = false // 타이머 상태를 추적

    init() {
        restoreTimer()
    }
    
    func startTimer() {
        let endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        defaults.set(endDate, forKey: "timerEndDate")
        runTimer()
        timerIsActive = true
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        defaults.removeObject(forKey: "timerEndDate")
        timerIsActive = false
    }

    func runTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateTimer()
        }
        timerIsActive = true
    }

    func updateTimer() {
        if let savedEndDate = defaults.object(forKey: "timerEndDate") as? Date {
            remainingSeconds = Int(savedEndDate.timeIntervalSinceNow)
            if remainingSeconds <= 0 {
                resetTimer()
            }
        }
    }

    func resetTimer() {
        remainingSeconds = 3600
        stopTimer()
    }

    func restoreTimer() {
        if let savedEndDate = defaults.object(forKey: "timerEndDate") as? Date {
            if savedEndDate > Date() {
                remainingSeconds = Int(savedEndDate.timeIntervalSinceNow)
                runTimer()
            } else {
                remainingSeconds = 3600
                stopTimer()
            }
        }
    }

    var timeFormatted: String {
        let hours = remainingSeconds / 3600
        let minutes = (remainingSeconds % 3600) / 60
        let seconds = (remainingSeconds % 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
