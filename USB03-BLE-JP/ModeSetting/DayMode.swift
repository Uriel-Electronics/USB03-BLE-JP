//
//  DayMode.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreBluetooth

struct BitSet {
    private(set) var value: UInt8 {
        didSet {
            UserDefaults.standard.set(value, forKey: "selectedDays")
        }
    }
    
    init() {
        self.value = UInt8(UserDefaults.standard.integer(forKey: "selectedDays"))
        if self.value == 0 {
            self.value = 127
        }
    }
    
    mutating func set(day: Int) {
        value |= (1 << day)
    }

    mutating func clear(day: Int) {
        value &= ~(1 << day)
    }

    func isSet(day: Int) -> Bool {
        return (value & (1 << day)) != 0
    }
}

struct DayMode: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var days = BitSet()
    @State private var showingAlert = false
    @State private var pendingIndex: Int?
    @State private var pendingValue: Bool = false
    @State private var alertMessage = ""
    
    let dayNames = ["月","火","水","木","金","土","日"]
    
    var body: some View {
        ZStack {
            Color.urielBlack.ignoresSafeArea()
            
            VStack {
                Text("曜日選択")
                    .font(Font.custom("Pretendard", size: 20).weight(.bold))
                    .foregroundColor(.textLight)
                //    .padding()
                
                ScrollView {
                    ForEach(dayNames.indices, id: \.self) { index in
                    VStack (spacing: 10) {
                        HStack (spacing: 50){
                            VStack (alignment: .leading) {
                                
                                    Toggle(isOn: Binding(
                                        get: { self.days.isSet(day: index) },
                                        set: { isOn in
                                            if isOn {
                                                self.days.set(day: index)
                                                self.showingAlert = true
                                            } else {
                                                self.days.clear(day: index)
                                            }
                                        }
                                    )) {
                                        Text(self.dayNames[index])
                                            .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                            .foregroundColor(.textLight)
                                            .tracking(1)
                                            .padding()
                                            .cornerRadius(12)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    .frame(maxWidth: .infinity)
                    .background(Color.bgLightDark)
                    .cornerRadius(12)
                    .padding()
                    
                    // .padding(.top, -15)
                    
                    Button(action: {
                        updateBluetoothDevice()
                    }) {
                        HStack {
                            Text("確認")
                                .font(Font.custom("Pretendard", size: 18).weight(.bold))
                        }
                        .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.bottom)
                    }
                    .padding()
                }
            }

        }
    }
    
    func updateBluetoothDevice() {
        print(String(format: "Selected days in binary: %08b", days.value))
        print(String(format: "Selected days in hex: %02X", days.value))
        print(days.value)
        
        if !bluetoothManager.bluetoothIsReady {
            
            return
        }
        
        let daysData = days.value
        
        let CHECKSUM: UInt8 = 207 &+ 8 &+ daysData
        print(CHECKSUM)
        
        let packet: [UInt8] = [207, 8, daysData, 0, 0, 0, 0, 0, 0, 0, 0, CHECKSUM, 13, 10]
        print(packet)
        
        bluetoothManager.sendBytesToDevice(packet)
        alertMessage = "曜日の設定を完了しました」"
        showingAlert = true
        
        presentationMode.wrappedValue.dismiss()
    }
}

