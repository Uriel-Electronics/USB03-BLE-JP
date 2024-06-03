//
//  ModeSettingView6.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreBluetooth

struct ModeSettingView6: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var Mode6OnTime: Date = UserDefaults.standard.object(forKey: "Mode6 OnTime") as? Date ?? Date() // 일몰 전 시간
    @State private var Mode6OffTime: Date = UserDefaults.standard.object(forKey: "Mode6 OffTime") as? Date ?? Date() // 일몰 후 시간
    @State private var Mode6OnTime2: Date = UserDefaults.standard.object(forKey: "Mode6 OnTime2") as? Date ?? Date()
    @State private var Mode6OffTime2: Date = UserDefaults.standard.object(forKey: "Mode6 OffTime2") as? Date ?? Date()
    @State private var showingAlert = false // Alert 표시 상태
    @State private var alertMessage = "" // Alert에 표시할 메시지
    
    var startTime: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 9)!
        return calendar.startOfDay(for: Date())
    }
    
    var endTime: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!  // GMT 시간대 설정
        return calendar.date(byAdding: .day, value: 1, to: startTime)!  // 오늘 날짜의 24시간 후 시간
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack {
                    VStack {
                        VStack {
                            Text("モード運転６")
                                .font(Font.custom("Pretendard", size: 16).weight(.bold))
                                .foregroundColor(.textLight)
                                .opacity(0.5)
                                .padding()
                            
                            Text("ONタイマー設定、OFFタイマー設定")
                                .font(Font.custom("Pretendard", size: 24).weight(.bold))
                                .foregroundColor(.textLight)
                            
                            Text("2回選択")
                                .font(Font.custom("Pretendard", size: 24).weight(.bold))
                                .foregroundColor(.textLight)
                            
                            HStack(alignment: .top, spacing: 4) {
                                HStack(spacing: 0) {
                                    Text("\(dateToOnTime(date: Mode6OnTime))")
                                        .font(Font.custom("Pretendard", size: 13).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top:12, leading: 9, bottom: 12, trailing: 10))
                                .cornerRadius(8)
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Text("\(dateToOffTime(date: Mode6OffTime))")
                                        .font(Font.custom("Pretendard", size: 13).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top:12, leading: 9, bottom: 12, trailing: 10))
                                .cornerRadius(8)
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Text("\(dateToOnTime2(date: Mode6OnTime2))")
                                        .font(Font.custom("Pretendard", size: 13).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top:12, leading: 0, bottom: 12, trailing: 0))
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Text("\(dateToOffTime2(date: Mode6OffTime2))")
                                        .font(Font.custom("Pretendard", size: 13).weight(.semibold))
                                        .lineSpacing(12)
                                        .foregroundColor(.textLight)
                                }
                                .padding(EdgeInsets(top:12, leading: 9, bottom: 12, trailing: 10))
                                .cornerRadius(8)
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .frame(maxWidth: .infinity)
                            .background(
                              LinearGradient(gradient: Gradient(colors: [Color(red: 0.13, green: 0.12, blue: 0.52), Color(red: 0, green: 0.94, blue: 1)]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .padding(EdgeInsets(top: 12, leading: 14, bottom: -6, trailing: 14))
                            
                            
                            HStack(alignment: .top, spacing: 0) {
                                VStack {}.frame(width: 2, height: 16).background(Color.urielDarkBlue)
                                
                                Spacer()
                                
                                VStack {}.frame(width: 2, height: 16).background(Color.urielDarkBlue)
                                
                                Spacer()
                                
                                VStack {}.frame(width: 2, height: 16).background(Color.urielBlue)
                                
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
                                // .frame(width: 83, height: 40)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(8)
                                HStack(spacing: 0) {
                                    Text("ON")
                                        .font(Font.custom("Pretendard", size: 12).weight(.bold))
                                        .lineSpacing(12)
                                        .foregroundColor(.black)
                                }
                                .padding(EdgeInsets(top: 14, leading: 0, bottom: 14, trailing: 0))
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
                            VStack(alignment: .leading) {
                                VStack {
                                    Text("1回目ONタイマー設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                HStack {
                                    DatePicker("One Timer ON", selection: $Mode6OnTime, displayedComponents: .hourAndMinute)
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
                            
                            
                            // 새벽에 켜지는 시간 (onTime2)
                            VStack(alignment: .leading) {
                                VStack {
                                    Text("1回目OFFタイマー設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                HStack {
                                    DatePicker("One Timer OFF", selection: $Mode6OffTime, displayedComponents: .hourAndMinute)
                                    
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
                            
                            Image(systemName: "arrow.down")
                                .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                .foregroundColor(.textLight)
                                .opacity(0.5)
                            
                            
                            VStack(alignment: .leading) {
                                VStack {
                                    Text("２回目ONタイマー設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                HStack {
                                    DatePicker("Two Timer ON", selection: $Mode6OnTime2, displayedComponents: .hourAndMinute)
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
                                    Text("２回目OFFタイマー設定")
                                        .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                        .foregroundColor(.textLight)
                                }
                                
                                HStack {
                                    DatePicker("Two Timer OFF", selection: $Mode6OffTime2, displayedComponents: .hourAndMinute)
                                    
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
                                    sendMode6Data()
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
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("警告"), message: Text(alertMessage), dismissButton: .default(Text("確認")))
                        }
                    }
                }
            }
        }
    }
    
    func sendMode6Data() {
        if !bluetoothManager.bluetoothIsReady {
            return
        }
        
        // let onTimeData2 = onTime2
        let onTimeminutes = dateToMinutes(date: Mode6OnTime)
        let onTimeresult: UInt16 = UInt16(onTimeminutes)
        let onTimeupperByte = UInt8(onTimeresult >> 8)
        let onTimelowerByte = UInt8(onTimeresult & 0x00FF)
        
        // let onTimeData2 = onTime2
        let offTimeminutes = dateToMinutes(date: Mode6OffTime)
        let offTimeresult: UInt16 = UInt16(offTimeminutes)
        let offTimeupperByte = UInt8(offTimeresult >> 8)
        let offTimelowerByte = UInt8(offTimeresult & 0x00FF)
        
        
        // let onTimeData2 = onTime2
        let onTime2minutes = dateToMinutes(date: Mode6OnTime2)
        let onTime2result: UInt16 = UInt16(onTime2minutes)
        let onTime2upperByte = UInt8(onTime2result >> 8)
        let onTime2lowerByte = UInt8(onTime2result & 0x00FF)
        
        // let offTimeData2 = offTime2
        let offTime2minutes = dateToMinutes(date: Mode6OffTime2)
        let offTime2result: UInt16 = UInt16(offTime2minutes)
        let offTime2upperByte = UInt8(offTime2result >> 8)
        let offTime2lowerByte = UInt8(offTime2result & 0x00FF)
        
        if (offTimeminutes >= onTime2minutes) {
            alertMessage = "2回目のONする時間を1回目のOFFする時間より遅く設定してください。"
            showingAlert = true
            return
        }
//        else if (onTimeminutes <= offTime2minutes) {
//            alertMessage = "1회차 켜지는 시간을\n2회차 꺼지는 시간보다 늦게 설정해주세요."
//            showingAlert = true
//            return
//        }
        
        let CHECKSUM = 207 &+ 6 &+ onTimeupperByte &+ onTimelowerByte &+ offTimeupperByte &+ offTimelowerByte &+ onTime2upperByte &+ onTime2lowerByte &+ offTime2upperByte &+ offTime2lowerByte
        print(CHECKSUM)
        
        let packet: [UInt8] = [207, 6, 0, onTimeupperByte, onTimelowerByte, offTimeupperByte, offTimelowerByte, onTime2upperByte, onTime2lowerByte, offTime2upperByte, offTime2lowerByte, CHECKSUM, 13, 10]
        
        print(packet)
        bluetoothManager.sendBytesToDevice(packet)
        // Change Label Text expression "success" for waiting
        // serialMessageLabel.text = "waiting msg from peripheral"
        alertMessage = "データを正常に伝送しました。"
        showingAlert = true
        
        UserDefaults.standard.set(Mode6OnTime, forKey: "Mode6 OnTime")
        UserDefaults.standard.set(Mode6OffTime, forKey: "Mode6 OffTime")
        UserDefaults.standard.set(Mode6OnTime2, forKey: "Mode6 OnTime2")
        UserDefaults.standard.set(Mode6OffTime2, forKey: "Mode6 OffTime2")
        UserDefaults.standard.set("모드 6, 설정 시간 ON/OFF, 2회 반복", forKey: "selectedMode")
        
        self.presentationMode.wrappedValue.dismiss()
    }
    
    func dateToOnTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let formattedDate = formatter.string(from: Mode6OnTime)
        
        return formattedDate
    }
    
    func dateToOffTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let formattedDate = formatter.string(from: Mode6OffTime)
        
        return formattedDate
    }
    
    func dateToOnTime2(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let formattedDate = formatter.string(from: Mode6OnTime2)
        
        return formattedDate
    }
    
    func dateToOffTime2(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let formattedDate = formatter.string(from: Mode6OffTime2)
        
        return formattedDate
    }
    
    func dateToMinutes(date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        return hour * 60 + minute
    }
}
