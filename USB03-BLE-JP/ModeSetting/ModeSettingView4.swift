//
//  ModeSettingView4.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreBluetooth

struct ModeSettingView4: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @StateObject private var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSegment2: Int = 1 // 0, 1, 2
    @State private var selectedSegmentText2: Int = 1 // 0, 1
    
    @State private var Mode4OnTime2: Date = UserDefaults.standard.object(forKey: "Mode4 OnTime2") as? Date ?? Date()
    @State private var Mode4OffTime: Int = UserDefaults.standard.integer(forKey: "Mode4 OffTime") // 일몰 후 시간
    
    @State private var showingAlert = false // Alert 표시 상태
    @State private var alertMessage = "" // Alert에 표시할 메시지
    
    let segmentTitles2 = ["日出前", "日出定刻", "日出後"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    VStack {
                        VStack {
                            Text("モード運転4")
                                .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                .foregroundColor(.textLight)
                                .opacity(0.5)
                                .padding()
                            
                            Text("早朝ON、日出OFF")
                                .font(Font.custom("Pretendard", size: 24).weight(.bold))
                                .foregroundColor(.textLight)
                            
                            HStack(alignment: .top, spacing: 4) {
                                HStack(spacing: 0) {
                                    Text("日没")
                                        .font(Font.custom("Pretendard", size: 16).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top:12, leading: 9, bottom: 12, trailing: 10))
                                .cornerRadius(8)
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Text("早朝")
                                        .font(Font.custom("Pretendard", size: 16).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top:12, leading: 0, bottom: 12, trailing: 0))
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Text("日出")
                                        .font(Font.custom("Pretendard", size: 16).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top:12, leading: 9, bottom: 12, trailing: 10))
                                .cornerRadius(8)
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(red: 1, green: 0.30, blue:0), Color(red: 0.13, green: 0.12, blue: 0.52), Color(red: 0, green: 0.94, blue: 1)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .padding(EdgeInsets(top: 12, leading: 14, bottom: -6, trailing: 14))
                            
                            
                            HStack(alignment: .top, spacing: 0) {
                                VStack {}.frame(width: 2, height: 16).background(Color.urielRed)
                                
                                Spacer()
                                
                                VStack {}.frame(width: 2, height: 16).background(Color.urielDarkBlue)
                                
                                Spacer()
                                
                                VStack {}.frame(width: 2, height: 16).background(Color.urielBlue)
                            }
                            .padding(EdgeInsets(top: 0, leading: 56, bottom: 0, trailing: 56))
                            .frame(maxWidth: .infinity)
                            
                            
                            HStack(spacing: 2) {
                              HStack(spacing: 0) {
                                Text("OFF")
                                  .font(Font.custom("Pretendard", size: 12).weight(.bold))
                                  .lineSpacing(12)
                                  .foregroundColor(.white)
                                  .opacity(0.50)
                              }
                              .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
                              .frame(maxWidth: .infinity)
                              .cornerRadius(8)
                              HStack(spacing: 0) {
                                Text("ON")
                                  .font(Font.custom("Pretendard", size: 12).weight(.bold))
                                  .lineSpacing(12)
                                  .foregroundColor(.black)
                              }
                              .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
                              // .frame(width: 84, height: 40)
                              .frame(maxWidth: .infinity)
                              .background(.white)
                              .cornerRadius(8)
                              VStack(spacing: 0) {
                                Text("OFF")
                                  .font(Font.custom("Pretendard", size: 12).weight(.bold))
                                  .lineSpacing(12)
                                  .foregroundColor(.white)
                                  .opacity(0.50)
                              }
                              .padding(EdgeInsets(top: 14, leading: 5, bottom: 14, trailing: 5))
                              .frame(height: 40)
                              .cornerRadius(8)
                            }
                            .padding(EdgeInsets(top: 12, leading: 6, bottom : 12, trailing: 6))
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.13, green: 0.14, blue: 0.15))
                            .cornerRadius(12)
                            .padding(EdgeInsets(top: -12, leading: 14, bottom: 24, trailing: 14))
                        }
                        .background(Color.black)
                        
                        
                        
                        VStack {
                            // 새벽에 켜지는 시간 (onTime2)
                            VStack(alignment: .leading) {
                                VStack {
                                    Text("早朝時にONする時間設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                HStack {
                                    DatePicker("Before Sunrise", selection: $Mode4OnTime2, displayedComponents: .hourAndMinute)
                                    
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .labelsHidden()
                                        .frame(height: 100)
                                        .padding(8)
                                    
                                    Text("ONする")
                                        .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                        .foregroundColor(.textLight)
                                        .opacity(0.5)
                                }
                                .padding(EdgeInsets(top: 40, leading: 12, bottom: 6, trailing: 12))
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                            .cornerRadius(24)
                            .padding()
                            
                            
                            Image(systemName: "arrow.down")
                                .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                .foregroundColor(.textLight)
                                .opacity(0.5)
                            
                            
                            VStack(alignment: .leading) {
                                
                                VStack {
                                    Text("日出時にOFFする時間設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.urielBlack)
                                            .frame(width: geometry.size.width, height: geometry.size.height)
                                        
                                        // 선택 표시 배경
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(width: geometry.size.width / CGFloat(segmentTitles2.count) - 2, height: 38)
                                            .cornerRadius(12)
                                            .offset(x: CGFloat(selectedSegment2) * (geometry.size.width / CGFloat(segmentTitles2.count)), y: 0)
                                            .animation(.easeInOut(duration: 0.3), value: selectedSegment2)
                                        
                                        
                                        HStack(spacing: 0) {
                                            ForEach(0..<segmentTitles2.count, id: \.self) { index in
                                                Text(self.segmentTitles2[index])
                                                    .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                                    .foregroundColor(self.selectedSegment2 == index ? .black : .white)
                                                    .frame(width: geometry.size.width / CGFloat(self.segmentTitles2.count), height: 40)
                                                    .background(Color.clear)
                                                    .onTapGesture {
                                                        self.selectedSegment2 = index
                                                        switch index {
                                                        case 0:
                                                            self.Mode4OffTime = -60 // "일몰 전" 선택 시
                                                        case 1:
                                                            self.Mode4OffTime = 0 // "일몰 정각" 선택 시
                                                        case 2:
                                                            self.Mode4OffTime = 60 // "일몰 후" 선택 시
                                                        default:
                                                            break
                                                        }
                                                    }
                                            }
                                        }
                                        
                                    }
                                    .frame(height: 56)
                                    .background(.urielBlack)
                                    .cornerRadius(12)
                                }
                                .padding()
                                .frame(height: 48)
                                
                                HStack {
                                    Text("日出")
                                    
                                    // 일출 후 시간 선택
                                    Picker("After Sunrise:", selection: $Mode4OffTime) {
                                        ForEach(-60..<61) { minute in
                                            Text("\(minute)").tag(minute)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .background(Color.urielBlack)
                                    .frame(height: 100)
                                    .cornerRadius(16)
                                    .onChange(of: Mode4OffTime) { newValue in
                                        if newValue < 0 {
                                            selectedSegment2 = 0
                                            selectedSegmentText2 = 0
                                        } else if newValue == 0 {
                                            selectedSegment2 = 1
                                            selectedSegmentText2 = 1
                                        } else {
                                            selectedSegment2 = 2
                                            selectedSegmentText2 = 1
                                        }
                                    }
                                    
                                    Text("分 \(segmentText(for: selectedSegmentText2)) OFFする")
                                }
                                .padding(EdgeInsets(top: 40, leading: 12, bottom : 6, trailing: 12))
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                            .cornerRadius(24)
                            .padding()
                            
                            Image(systemName: "arrow.down")
                                .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                .foregroundColor(.textLight)
                                .opacity(0.5)
                            
                            
                            HStack(spacing: 8) {
                                Button("キャンセル") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                                .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                
                                Button("確認") {
                                    sendMode4Data()
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                .foregroundColor(.urielBlack)
                                .cornerRadius(12)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .background(Color.urielBlack)
                        .cornerRadius(24)
                    }
                }
            }
        }
    }
    
    func segmentText(for index: Int) -> String {
        switch index {
        case 0:
            return "前"
        case 1:
            return "後"
        default:
            return "後"
        }
    }
    
    func sendMode4Data() {
        if (Mode4OffTime < 0) {
            // let onTimeData2 = onTime2
            let onTime2minutes = dateToMinutes(date: Mode4OnTime2)
            let onTime2result: UInt16 = UInt16(onTime2minutes)
            let onTime2upperByte = UInt8(onTime2result >> 8)
            let onTime2lowerByte = UInt8(onTime2result & 0x00FF)
            
            let offTimeData = Mode4OffTime
            
            let negativeOffTime: Int16 = Int16(offTimeData)
            let negativeOffTimeUInt16 = UInt16.init(bitPattern: negativeOffTime)
            
            let negativeOffTimeUInt1 = UInt8(negativeOffTimeUInt16 >> 8)
            let negativeOffTimeUInt2 = UInt8(negativeOffTimeUInt16 & 0x00FF)
            
            let CHECKSUM = 207 &+ 4 &+ negativeOffTimeUInt1 &+ negativeOffTimeUInt2 &+ onTime2upperByte &+ onTime2lowerByte
            print(CHECKSUM)
            
            let packet: [UInt8] = [207, 4, 0, 0, 0, negativeOffTimeUInt1, negativeOffTimeUInt2, onTime2upperByte, onTime2lowerByte, 0, 0, CHECKSUM, 13, 10]
            
            print(packet)
            bluetoothManager.sendBytesToDevice(packet)
            // Change Label Text expression "success" for waiting
            // serialMessageLabel.text = "waiting msg from peripheral"
            alertMessage = "データを正常に伝送しました。"
            showingAlert = true
            
            UserDefaults.standard.set(Mode4OnTime2, forKey: "Mode4 OnTime")
            UserDefaults.standard.set(Mode4OffTime, forKey: "Mode4 OffTime")
            UserDefaults.standard.set("모드 4, 새벽 켜짐, 일출 꺼짐", forKey: "selectedMode")
            self.presentationMode.wrappedValue.dismiss()
        } else if (Mode4OffTime >= 0) {
            // let onTimeData2 = onTime2
            let onTime2minutes = dateToMinutes(date: Mode4OnTime2)
            let onTime2result: UInt16 = UInt16(onTime2minutes)
            let onTime2upperByte = UInt8(onTime2result >> 8)
            let onTime2lowerByte = UInt8(onTime2result & 0x00FF)
            
            let offTimeData = UInt8(Mode4OffTime)
            
            let CHECKSUM = 207 &+ 4 &+ offTimeData &+ onTime2upperByte &+ onTime2lowerByte
            print(CHECKSUM)
            
            let packet: [UInt8] = [207, 4, 0, 0, 0, 0, offTimeData, onTime2upperByte, onTime2lowerByte, 0, 0, CHECKSUM, 13, 10]
            print(packet)
            bluetoothManager.sendBytesToDevice(packet)
            // Change Label Text expression "success" for waiting
            // serialMessageLabel.text = "waiting msg from peripheral"
            alertMessage = "データを正常に伝送しました。"
            showingAlert = true
            
            UserDefaults.standard.set(Mode4OnTime2, forKey: "Mode4 OnTime2")
            UserDefaults.standard.set(Mode4OffTime, forKey: "Mode4 OffTime")
            UserDefaults.standard.set("모드 4, 새벽 켜짐, 일출 꺼짐", forKey: "selectedMode")
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func dateToMinutes(date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return hour * 60 + minute
    }
}

