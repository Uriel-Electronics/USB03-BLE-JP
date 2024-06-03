//
//  ContentView.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreLocation


struct ContentView: View {
    @State var showSplash: Bool = false
    var body: some View {
        ZStack {
            if self.showSplash {
                MainView()
            } else {
                SplashScreenView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    self.showSplash = true
                }
            }
        }
    }
        
}

struct MainView: View {
    @ObservedObject var bluetoothManager = BluetoothManager()
    @ObservedObject private var locationManager = LocationManager() // 위치 관리자 인스턴스 생성
    @EnvironmentObject var timerManager: TimeManager
    
    @State private var isShowingModal = false
    @State private var currentDate = Date()
    @State private var buttonActionTriggered = false
    @State private var navigateToLanding = false
    @State private var navigateToScan = false
    @State private var navigateToSetting = false
    private let videoID = "gWstaniV0Jw"

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            
            formatter.dateFormat = "yyyy年 M月 d日 EEEE" //
            formatter.locale = Locale(identifier: "ja_JP") // 사용자의 현재 로케일 설정을 사용
            return formatter
        }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "a hh:mm:ss"
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter
    }
    
    var body: some View {
        
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    if navigateToLanding {
                        LandingView(bluetoothManager: bluetoothManager, navigateToLanding: $navigateToLanding)
                    }
                    else {
                        Color.urielBlack.ignoresSafeArea()
                        
                        VStack() {
                            Text("Uriel")
                                .font(Font.custom("Pretendard", size: 20).weight(.bold))
                                .foregroundColor(.textLight)
                            
                            VStack {
                                Text(dateFormatter.string(from: timerManager.currentDate))
                                    .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                    .foregroundColor(.textLight)
                                    .onReceive(timer) { _ in
                                        currentDate = Date() // 현재 날짜로 업데이트
                                    }
                                    .padding(.top, 8)
                                
                                Text(timeFormatter.string(from: timerManager.currentDate))
                                
                                    .font(Font.custom("Pretendard", size: 28).weight(.bold))
                                    .lineSpacing(28)
                                    .foregroundColor(.textLight)
                                    .onReceive(timer) { input in
                                        currentDate = input
                                    }
                                    .padding(.top, 2)
                                    .padding(.bottom)
                                
                                HStack {
                                    HStack {
                                        Text("日出")
                                            .font(Font.custom("Pretendard", size: 15).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .opacity(0.70)
                                        
                                        Text(locationManager.sunrise)
                                            .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .padding(.horizontal)
                                    }
                                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 20))
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 1, green: 1, blue: 1).opacity(0.15))
                                    .cornerRadius(12)
                                    
                                    HStack {
                                        Text("日没")
                                            .font(Font.custom("Pretendard", size: 15).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .opacity(0.70)
                                        
                                        Text(locationManager.sunset)
                                            .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .padding(.horizontal)
                                    }
                                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 1, green: 1, blue: 1).opacity(0.15))
                                    .cornerRadius(12)
                                    
                                }
                                
                                HStack {
                                    HStack {
                                        Text("緯度")
                                            .font(Font.custom("Pretendard", size: 15).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .opacity(0.70)
                                        
                                        Text(locationManager.latitude)
                                            .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .padding(.horizontal)
                                    }
                                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 20))
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 1, green: 1, blue: 1).opacity(0.15))
                                    .cornerRadius(12)
                                    .padding(.top, 6)
                                    HStack {
                                        Text("経度")
                                            .font(Font.custom("Pretendard", size: 15).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .opacity(0.70)
                                        
                                        Text(locationManager.longitude)
                                            .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                            .lineSpacing(12)
                                            .foregroundColor(.textLight)
                                            .padding(.horizontal)
                                    }
                                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 1, green: 1, blue: 1).opacity(0.15))
                                    .cornerRadius(12)
                                    .padding(.top, 6)
                                    
                                }
                                .padding(.bottom, 6)
                                
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.52, blue: 1), Color(red: 0.34, green: 0.76, blue: 1)]), startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(24)
                            .padding()
                            
                            
                            
                            VStack(spacing:20) {
                                
                                Text("機器を設置してから下のボタンを押して機器と繋がってください。")
                                    .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                    .lineSpacing(8)
                                    .foregroundColor(.textLight)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                
                                Button(action : {
                                    isShowingModal = true
                                }) {
                                    HStack {
                                        Text("機器の追加")
                                            .font(Font.custom("Pretendard", size: 18).weight(.bold))
                                    }
                                    .padding(EdgeInsets(top: 15, leading: 95, bottom:15, trailing: 95))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .padding(.bottom)
                                }
                                .sheet(isPresented: $isShowingModal) {
                                    ScanView(bluetoothManager:bluetoothManager, navigateToSetting: $navigateToSetting, navigateToLanding: $navigateToLanding)
                                }
                                
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                            .cornerRadius(24)
                            .padding()
                            .padding(.top, -20)
                            
                            VStack {
                                Text("使用説明動画")
                                    .font(Font.custom("Pretendard", size: 17).weight(.bold))
                                    .foregroundColor(.textLight)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                
                                YouTubeView(videoID: videoID)
                                    .cornerRadius(24)
                            }
                            .padding(20)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.22, green: 0.23, blue: 0.25))
                            .cornerRadius(24)
                            .padding()
                            .padding(.top, -20)
                            
                        }
                        .padding(.top, 12)
                        
                        
                    }
                }
                .onAppear {
                    bluetoothManager.loadPeripheralList()
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
}

struct SplashScreenView: View {
    var body: some View {
        Color.urielBlack.ignoresSafeArea()
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            Image("Splash")
                .resizable()
                .frame(width: 140, height: 140)
                .padding(.vertical, 175)
            Image("SplashWord")
                .resizable()
                .frame(width: 120, height: 30)
        }
            
    }
}


//#Preview {
//    ContentView()
//}
