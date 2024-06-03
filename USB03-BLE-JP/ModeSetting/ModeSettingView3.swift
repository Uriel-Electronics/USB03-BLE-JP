//
//  ModeSettingView3.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreBluetooth

struct ModeSettingView3: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @StateObject private var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedSegment: Int = 1 // 0, 1, 2
    @State private var selectedSegmentText: Int = 1 // 0, 1
    
    @State private var Mode3OnTime: Int = UserDefaults.standard.integer(forKey: "Mode3 OnTime")
    @State private var Mode3OffTime2: Date = UserDefaults.standard.object(forKey: "Mode3 OffTime2") as? Date ?? Date()
    
    @State private var showingAlert = false // Alert 표시 상태
    @State private var alertMessage = "" // Alert에 표시할 메시지
    
    let segmentTitles = ["日没前", "日没定刻", "日没後"]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    VStack {
                        VStack {
                            Text("モード運転３")
                                .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                .foregroundColor(.textLight)
                                .opacity(0.5)
                                .padding()
                            
                            Text("日没ON,　夜間OFF")
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
                                    Text("夜間")
                                        .font(Font.custom("Pretendard", size: 16).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Text("日出")
                                        .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top: 12, leading: 9, bottom: 12, trailing: 10))
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
                                
                                VStack {}.frame(width: 2, height: 16).background(Color.urielPurple)
                                
                                Spacer()
                                
                                VStack {}.frame(width: 2, height: 16).background(Color.urielBlue)
                            }
                            .padding(EdgeInsets(top: 0, leading: 56, bottom: 0, trailing: 56))
                            .frame(maxWidth: .infinity)
                                                        
                            
                            HStack(spacing: 2) {
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
                              HStack(spacing: 0) {
                                Text("ON")
                                  .font(Font.custom("Pretendard", size: 12).weight(.bold))
                                  .lineSpacing(12)
                                  .foregroundColor(.black)
                              }
                              .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
                              //.frame(width: 84, height: 40)
                              .frame(maxWidth: .infinity)
                              .background(.white)
                              .cornerRadius(8)
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
                            }
                            .padding(EdgeInsets(top: 12, leading: 6, bottom : 12, trailing: 6))
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.13, green: 0.14, blue: 0.15))
                            .cornerRadius(12)
                            .padding(EdgeInsets(top: -12, leading: 14, bottom: 24, trailing: 14))
                        }
                        .background(Color.black)
                        
                        
                        VStack {
                            VStack(alignment: .leading) {
                                VStack {
                                    Text("日没時にONする時間設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Rectangle().fill(Color.urielBlack).frame(width: geometry.size.width, height: geometry.size.height)
                                        
                                        
                                        Rectangle().fill(Color.white).frame(width: geometry.size.width / CGFloat(segmentTitles.count), height: 38).cornerRadius(12).offset(x: CGFloat(selectedSegment) * (geometry.size.width / CGFloat(segmentTitles.count)), y: 0).animation(.easeInOut(duration:0.3), value: selectedSegment)
                                        
                                        HStack(spacing: 0) {
                                            ForEach(0..<segmentTitles.count, id: \.self)
                                            {
                                                index in Text(self.segmentTitles[index]).font(Font.custom("Pretendard", size: 16).weight(.bold)).foregroundColor(self.selectedSegment == index ? .black : .white).frame(width: geometry.size.width / CGFloat(self.segmentTitles.count), height: 40).background(Color.clear).onTapGesture {
                                                    self.selectedSegment = index
                                                    switch index {
                                                    case 0:
                                                        self.Mode3OnTime = -60
                                                    case 1:
                                                        self.Mode3OnTime = 0
                                                    case 2:
                                                        self.Mode3OnTime = 60
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
                                    Text("日没")
                                    
                                    // 일몰 전후 60분 선택
                                    Picker("Before Sunset:", selection: $Mode3OnTime) {
                                        ForEach(-60..<61) { minute in
                                            Text("\(minute)").tag(minute)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 100)
                                    .background(Color.urielBlack)
                                    .cornerRadius(16)
                                    .onChange(of: Mode3OnTime) { newValue in
                                        if newValue < 0 {
                                            selectedSegment = 0
                                            selectedSegmentText = 0
                                        } else if newValue == 0 {
                                            selectedSegment = 1
                                            selectedSegmentText = 1
                                        } else {
                                            selectedSegment = 2
                                            selectedSegmentText = 1
                                        }
                                        
                                    }
                                    
                                    Text("分 \(segmentText(for: selectedSegmentText)) ONする")
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
                            
                            // 밤 중에 꺼지는 시간 (offTime2)
                            VStack(alignment: .leading) {
                                VStack {
                                    Text("夜間時にOFFする時間設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                HStack {
                                    DatePicker("Before Sunset:", selection: $Mode3OffTime2, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .labelsHidden()
                                        .frame(height: 100)
                                        .padding(8)
                                    
                                    Text("OFFする")
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
                                    sendMode3Data()
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
    
    func sendMode3Data() {
        if !bluetoothManager.bluetoothIsReady {
            return
        }
        
        if (Mode3OnTime < 0) {
            let onTimeData = Mode3OnTime
            
            let negativeOnTime: Int16 = Int16(onTimeData)
            let negativeOnTimeUInt16 = UInt16.init(bitPattern: negativeOnTime)
            
            let negativeOnTimeUInt1 = UInt8(negativeOnTimeUInt16 >> 8)
            let negativeOnTimeUInt2 = UInt8(negativeOnTimeUInt16 & 0x00FF)
            
            
            // let offTimeData2 = offTime2
            let offTime2minutes = dateToMinutes(date: Mode3OffTime2)
            let offTime2result: UInt16 = UInt16(offTime2minutes)
            let offTime2upperByte = UInt8(offTime2result >> 8)
            let offTime2lowerByte = UInt8(offTime2result & 0x00FF)
            
            let CHECKSUM = 207 &+ 3 &+ negativeOnTimeUInt1 &+ negativeOnTimeUInt2 &+ offTime2upperByte &+ offTime2lowerByte
            print(CHECKSUM)
            
            let packet: [UInt8] = [207, 3, 0, negativeOnTimeUInt1, negativeOnTimeUInt2, 0, 0, 0, 0, offTime2upperByte, offTime2lowerByte, CHECKSUM, 13, 10]
            print(packet)
            bluetoothManager.sendBytesToDevice(packet)
            alertMessage = "データを正常に伝送しました。"
            showingAlert = true
            
            UserDefaults.standard.set(Mode3OnTime, forKey: "Mode3 OnTime")
            UserDefaults.standard.set(Mode3OffTime2, forKey: "Mode3 OffTime2")
            UserDefaults.standard.set("모드 3, 일몰 켜짐, 밤중 꺼짐", forKey: "selectedMode")
            self.presentationMode.wrappedValue.dismiss()
            
        } else if (Mode3OnTime >= 0) {
            let onTimeData = UInt8(Mode3OnTime)
            
            // let offTimeData2 = offTime2
            let offTime2minutes = dateToMinutes(date: Mode3OffTime2)
            let offTime2result: UInt16 = UInt16(offTime2minutes)
            let offTime2upperByte = UInt8(offTime2result >> 8)
            let offTime2lowerByte = UInt8(offTime2result & 0x00FF)
            
            let CHECKSUM = 207 &+ 3 &+ onTimeData &+ offTime2upperByte &+ offTime2lowerByte
            print(CHECKSUM)
            
            let packet: [UInt8] = [207, 3, 0, 0, onTimeData, 0, 0, 0, 0, offTime2upperByte, offTime2lowerByte, CHECKSUM, 13, 10]
            print(packet)
            bluetoothManager.sendBytesToDevice(packet)
            alertMessage = "データを正常に伝送しました。"
            showingAlert = true
            
            UserDefaults.standard.set(Mode3OnTime, forKey: "Mode3 OnTime")
            UserDefaults.standard.set(Mode3OffTime2, forKey: "Mode3 OffTime2")
            UserDefaults.standard.set("모드 3, 일몰 켜짐, 밤중 꺼짐", forKey: "selectedMode")
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

