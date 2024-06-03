//
//  ScanView.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreBluetooth

struct ScanView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var navigateToSetting: Bool
    @Binding var navigateToLanding: Bool
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            Color.urielBlack.ignoresSafeArea()
            VStack {
                if isLoading {
                    Text("機器連結中").font(Font.custom("Pretendard", size: 24).weight(.bold)).foregroundColor(.textLight).padding(.top, 40)
                    
                    ProgressView("連結中...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .textLight))
                        .foregroundColor(.textLight)
                        .padding(.vertical, 20)
                } else {
                    Text("機器の検索").font(Font.custom("Pretendard", size: 20).weight(.bold)).foregroundColor(.textLight).padding(.top, 40)
                    Text("機器の検索ができなかった場合にはアプリを終了してブルートゥースを再起動してください。").font(Font.custom("Pretendard", size: 15).weight(.bold)).foregroundColor(.textLight).padding(.vertical, 20)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(bluetoothManager.discoveredDevices, id: \.identifier) { device in
                                Button(action: {
                                    self.isLoading = true
                                    self.bluetoothManager.connectToDevice(device)
                                }) {
                                    Text(bluetoothManager.findName(for: device.identifier.uuidString) ?? "USB-03")
                                        .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                        .foregroundColor(.urielBlack)
                                        .tracking(1)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onAppear {
                        bluetoothManager.loadPeripheralList()
                        bluetoothManager.onConnect = {
                            self.isLoading = false
                            self.navigateToSetting = true
                        }
                    }
                    .sheet(isPresented:$navigateToSetting) {
                        SettingView(bluetoothManager: bluetoothManager, navigateToLanding: $navigateToLanding)
                    }
                }
            }
        }
    }
}


