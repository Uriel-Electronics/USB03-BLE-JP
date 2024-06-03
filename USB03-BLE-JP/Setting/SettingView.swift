//
//  SettingView.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreBluetooth


struct SettingView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @ObservedObject private var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var navigateToLanding: Bool
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isTimeLoading = false
    @State private var isModeLoading = false
    
    var selectedMode: String {
        UserDefaults.standard.string(forKey: "selectedMode") ?? "選択されてない。"
    }
    
    var body: some View {
        ZStack {
            Color.urielBlack.ignoresSafeArea()
            
            VStack (spacing: 20) {
                if isModeLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    
                        
                    VStack {
                        
                        Text("モード運転の選択")
                            .font(Font.custom("Pretendard", size: 20).weight(.bold))
                            .lineSpacing(8)
                            .foregroundColor(.textLight)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                                
                                
                        Button(action: {
                            isModeLoading = true
                            sendData()
                            requestData()
                            isModeLoading = false
                        }) {
                            HStack {
                                Text("1. モード運転の選択")
                                    .font(Font.custom("Pretendard", size: 22).weight(.bold))
                            }
                            .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.bottom)
                        }
                        // .padding()
                    }
                                            
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                    .cornerRadius(24)
                    .padding()
                    .padding(.top, -20)
                }
                
                    if isTimeLoading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .textLight))
                            .padding()
                    } else {
                        VStack {
                            Text("機器の時間・位置情報の再設定")
                                .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                .lineSpacing(8)
                                .foregroundColor(.textLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            
                            Button (action: {
                                sendTimeData()
                                isTimeLoading = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    disconnectDevice()
                                    isTimeLoading = false
                                }
                            }){
                                HStack {
                                    Text("2. 時間の再設定")
                                        .font(Font.custom("Pretendard", size: 22).weight(.bold))
                                }
                                .padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding(.bottom)
                            }
                            //.padding()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                        .cornerRadius(24)
                        .padding()
                        .padding(.top, -20)
                    }
            }
            
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("お知らせ"), message: Text(alertMessage), dismissButton: .default(Text("確認")))
        }
    }
    
    func convertToUInt8Pair(value: Int) -> (upper: UInt8, lower: UInt8) {
        let upper = UInt8(value / 256)
        let lower = UInt8(value % 256)
        return (upper, lower)
    }
    
    func sendTimeData() {
        if !bluetoothManager.bluetoothIsReady {
            alertMessage = "ブルートゥースの準備ができていません。"
            showingAlert = true
            return
        }
        
        let date = Date()
        let yform = DateFormatter()
        let mform = DateFormatter()
        let dform = DateFormatter()
        let dayform = DateFormatter()
        let hhform = DateFormatter()
        let minform = DateFormatter()
        let ssform = DateFormatter()
        
        yform.dateFormat = "yyyy"
        mform.dateFormat = "MM"
        dform.dateFormat = "dd"
        dayform.dateFormat = "ccc"
        hhform.dateFormat = "HH"
        minform.dateFormat = "mm"
        ssform.dateFormat = "ss"
        
        let yy = yform.string(from: date)
        let mm = mform.string(from: date)
        let dd = dform.string(from: date)
        let day = dayform.string(from: date)
        print(day)
        let hh = hhform.string(from: date)
        let minute = minform.string(from: date)
        let ss = ssform.string(from: date)
        
        let YY = UInt8(Int(yy)! - 2000)
        print(YY)
        let MM = UInt8(Int(mm)!)
        print(MM)
        let DD = UInt8(Int(dd)!)
        print(DD)
        let DAY: UInt8 = {
            switch day {
            case "月": return 1
            case "火": return 2
            case "水": return 3
            case "木": return 4
            case "金": return 5
            case "土": return 6
            case "日": return 7
            default: return 0 // 잘못된 요일 값 처리
            }
        }()
        let HH = UInt8(Int(hh)!)
        let MIN = UInt8(Int(minute)!)
        let SS = UInt8(Int(ss)!)
        
        
        let LAT = locationManager.formattedLAT
        let LNG = locationManager.formattedLNG
        
        let bigLAT: Int16 = Int16(LAT)
        let bigLNG: Int16 = Int16(LNG)
        
        let upperLAT = UInt8(bigLAT >> 8)
        let lowerLAT = UInt8(bigLAT & 0x00FF)
        
        let upperLNG = UInt8(bigLNG >> 8)
        let lowerLNG = UInt8(bigLNG & 0x00FF)
        
        let _: Int16 = 0
        let _: Int16 = 0
               
        let CHECKSUM = 175 &+ YY &+ MM &+ DD &+ DAY &+ HH &+ MIN &+ SS &+ upperLAT &+ lowerLAT &+ upperLNG &+ lowerLNG &+ 5 &+ 70
        print(DAY)
        print(CHECKSUM)
        
        let packet: [UInt8] = [175, YY, MM, DD, DAY, HH, MIN, SS, upperLAT, lowerLAT, upperLNG, lowerLNG, 5, 70, CHECKSUM, 13, 10]
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
        
        alertMessage = "時間の再設定を完了しました。"
        showingAlert = true
        
        presentationMode.wrappedValue.dismiss()
        navigateToLanding = false
    }
    
    func disconnectDevice () {
        if !bluetoothManager.bluetoothIsReady {
            return
        }
        bluetoothManager.disconnectDevice()
    }
    
    func requestData() {
        if !bluetoothManager.bluetoothIsReady {
            alertMessage = "ブルートゥースの準備ができていません。"
            showingAlert = true
            return
        }
        
        let CHECKSUM: UInt8 = 207
        
        let packet: [UInt8] = [207, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, CHECKSUM, 13, 10]
        
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
    }
    
    func sendData() {
        if !bluetoothManager.bluetoothIsReady {
            alertMessage = "ブルートゥースの準備ができていません。"
            showingAlert = true
            return
        }
        
        let date = Date()
        let yform = DateFormatter()
        let mform = DateFormatter()
        let dform = DateFormatter()
        let dayform = DateFormatter()
        let hhform = DateFormatter()
        let minform = DateFormatter()
        let ssform = DateFormatter()
        
        yform.dateFormat = "yyyy"
        mform.dateFormat = "MM"
        dform.dateFormat = "dd"
        dayform.dateFormat = "ccc"
        hhform.dateFormat = "HH"
        minform.dateFormat = "mm"
        ssform.dateFormat = "ss"
        
        let yy = yform.string(from: date)
        let mm = mform.string(from: date)
        let dd = dform.string(from: date)
        let day = dayform.string(from: date)
        print(day)
        let hh = hhform.string(from: date)
        let minute = minform.string(from: date)
        let ss = ssform.string(from: date)
            
            
        // 시리얼의 delegate를 SerialViewController로 설정합니다.
        //serial.delegate = self
        
        let YY = UInt8(Int(yy)! - 2000)
        print(YY)
        let MM = UInt8(Int(mm)!)
        print(MM)
        let DD = UInt8(Int(dd)!)
        print(DD)
        let DAY: UInt8 = {
            switch day {
            case "月": return 1
            case "火": return 2
            case "水": return 3
            case "木": return 4
            case "金": return 5
            case "土": return 6
            case "日": return 7
            default: return 0 // 잘못된 요일 값 처리
            }
        }()
        let HH = UInt8(Int(hh)!)
        let MIN = UInt8(Int(minute)!)
        let SS = UInt8(Int(ss)!)
        
        
        let LAT = locationManager.formattedLAT
        let LNG = locationManager.formattedLNG
        
        let bigLAT: Int16 = Int16(LAT)
        let bigLNG: Int16 = Int16(LNG)
        
        let upperLAT = UInt8(bigLAT >> 8)
        let lowerLAT = UInt8(bigLAT & 0x00FF)
        
        let upperLNG = UInt8(bigLNG >> 8)
        let lowerLNG = UInt8(bigLNG & 0x00FF)
        
        let _: Int16 = 0
        let _: Int16 = 0
               
        let CHECKSUM = 175 &+ YY &+ MM &+ DD &+ DAY &+ HH &+ MIN &+ SS &+ upperLAT &+ lowerLAT &+ upperLNG &+ lowerLNG &+ 5 &+ 70
        print(DAY)
        print(CHECKSUM)
        
        let packet: [UInt8] = [175, YY, MM, DD, DAY, HH, MIN, SS, upperLAT, lowerLAT, upperLNG, lowerLNG, 5, 70, CHECKSUM, 13, 10]
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
        
        alertMessage = "機器の設定を完了しました。"
        showingAlert = true
        
        presentationMode.wrappedValue.dismiss()
        navigateToLanding = true
    }
}

