//
//  BluetoothManager.swift
//  USB03-BLE-JP
//
//  Created by 이요섭 on 6/3/24.
//

import SwiftUI
import CoreBluetooth

/// 블루투스와 관련된 일을 전담하는 글로벌 시리얼 핸들러입니다.
var serial : BluetoothManager!

// 블루투스를 연결하는 과정에서의 시리얼과 뷰의 소통을 위해 필요한 프로토콜입니다.
protocol BluetoothSerialDelegate : AnyObject {
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?)
    func serialDidConnectPeripheral(peripheral : CBPeripheral)
    func serialDidReceiveMessage(message : UInt16)
}

// 프로토콜에 포함되어 있는 일부 함수를 옵셔널로 설정합니다.
extension BluetoothSerialDelegate {
    func serialDidDiscoverPeripheral(peripheral : CBPeripheral, RSSI : NSNumber?) {}
    func serialDidConnectPeripheral(peripheral : CBPeripheral) {}
    func serialDidReceiveMessage(message : String) {}
}

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var discoveredDevices: [CBPeripheral] = []
    // @Published var discoveredDevices: [String: CBPeripheral] = [:]
    // @Published var devices = [CBPeripheral: String]()
    @Published var devices: [CBPeripheral] = []
    @Published var isConnected: Bool = false
    var onConnect: (() -> Void)?
    @Published var connectedDeviceIdentifier: String = ""
    @Published var connectedDeviceName: String = "USB-03"
    @Published var powerOn: Bool = false
    @Published var emergencyOn: Bool = false
    var peripheralList: [String: [String : String]] = [:]
    
    // BluetoothSerialDelegate 프로토콜에 등록된 메서드를 수행하는 delegate입니다.
    var delegate : BluetoothSerialDelegate?
    
    /// centralManager은 블루투스 주변기기를 검색하고 연결하는 역할을 수행합니다.
    var centralManager : CBCentralManager!
    var peripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    
    /// pendingPeripheral은 현재 연결을 시도하고 있는 블루투스 주변기기를 의미합니다.
    var pendingPeripheral : CBPeripheral?
    
    /// connectedPeripheral은 연결에 성공된 기기를 의미합니다. 기기와 통신을 시작하게되면 이 객체를 이용하게됩니다.
    var connectedPeripheral : CBPeripheral?
    
    /// 데이터를 주변기기에 보내기 위한 characteristic을 저장하는 변수입니다.
    weak var writeCharacteristic: CBCharacteristic?
    
    /// 데이터를 주변기기에 보내는 type을 설정합니다. withResponse는 데이터를 보내면 이에 대한 답장이 오는 경우입니다. withoutResponse는 반대로 데이터를 보내도 답장이 오지 않는 경우입니다.
    private var writeType: CBCharacteristicWriteType = .withoutResponse
    
    /// serviceUUID는 Peripheral이 가지고 있는 서비스의 UUID를 뜻합니다. 거의 모든 HM-10모듈이 기본적으로 갖고있는 FFE0으로 설정하였습니다. 하나의 기기는 여러개의 serviceUUID를 가질 수도 있습니다.
    var serviceUUID = CBUUID(string: "85D1488F-DB99-4DB0-8BC4-FD605A970185")
    
    /// characteristicUUID는 serviceUUID에 포함되어있습니다. 이를 이용하여 데이터를 송수신합니다. FFE0 서비스가 갖고있는 FFE1로 설정하였습니다. 하나의 service는 여러개의 characteristicUUID를 가질 수 있습니다.
    var characteristicUUID = CBUUID(string : "FFE1")
    
    /// 블루투스 기기와 성공적으로 연결되었고, 통신이 가능한 상태라면 true를 반환합니다.
    var bluetoothIsReady:  Bool  {
        get {
            return centralManager.state == .poweredOn &&
            connectedPeripheral?.name != nil &&
            writeCharacteristic != nil
        }
    }
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        loadPeripheralList()
    }
    
    func startScan() {
        guard centralManager.state == .poweredOn else { return }
        
        // CBCentralManager의 메서드인 scanForPeripherals를 호출하여 연결가능한 기기들을 검색합니다. 이 떄 withService 파라미터에 nil을 입력하면 모든 종류의 기기가 검색되고, 지금과 같이 serviceUUID를 입력하면 특정 serviceUUID를 가진 기기만을 검색합니다.
        // withService의 파라미터를 nil로 설정하면 검색 가능한 모든 기기를 검색합니다.
        // 새로운 주변기기가 연결될 때마다 centralManager(_:didDiscover:advertisementData:rssi:)를 호출합니다.
        centralManager.scanForPeripherals(withServices: nil, options: nil)
        
        // 이미 연결된 기기들을 peripherals 변수에 반환받는 과정입니다.
        let peripherals = centralManager.retrieveConnectedPeripherals(withServices: [serviceUUID])
        for peripheral in peripherals {
            // 연결된 기기들에 대한 처리를 코드로 작성합니다.
            delegate?.serialDidDiscoverPeripheral(peripheral: peripheral, RSSI: nil)
        }
    }
    
    /// 기기 검색을 중단합니다.
    func stopScan() {
        centralManager.stopScan()
    }
    
    
    func connectToDevice(_ device: CBPeripheral) {
        centralManager.connect(device, options: nil)
        print(device.name ?? "USB-03")
        print(device.identifier.uuidString)
        print(device.services ?? "nil")
        print(device.state)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isConnected = true
            self.onConnect?()
        }
    }
    
    
    // peripheral disconnecting
    func disconnectDevice() {
        guard let peripheral = connectedPeripheral else {
            print("No device is connected.")
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
        
    
    
    /// 데이터 Array를 Byte형식으로 주변기기에 전송합니다.
    func sendBytesToDevice(_ bytes: [UInt8]) {
        guard bluetoothIsReady else { return }
        
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }
    
    /// 데이터를 주변기기에 전송합니다.
    func sendDataToDevice(_ data: Data) {
        guard bluetoothIsReady else { return }
        
        connectedPeripheral!.writeValue(data, for: writeCharacteristic!, type: writeType)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
            centralManager.scanForPeripherals(withServices: nil, options: options)
        } else {
            // 적절한 오류 처리
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if peripheralList.keys.contains(peripheral.identifier.uuidString) {
            print("Target Device with UUID found")
        }
        
        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let targetManufacturerData = Data([0x94, 0xC9])
            
            if #available(iOS 16.0, *) {
                if manufacturerData.contains(targetManufacturerData) {
                    if !discoveredDevices.contains(peripheral) {
                        discoveredDevices.append(peripheral)
                    }
                }
            } else {
                // Fallback on earlier versions iOS 15.0
                let targetDataCount = targetManufacturerData.count
                let manufacturerDataCount = manufacturerData.count
                var found = false
                
                if manufacturerDataCount >= targetDataCount {
                    for i in 0...(manufacturerDataCount - targetDataCount) {
                        let range = i..<(i + targetDataCount)
                        if manufacturerData[range] == targetManufacturerData {
                            found = true
                            break
                        }
                    }
                }
                
                if found {
                    if !discoveredDevices.contains(peripheral) {
                        discoveredDevices.append(peripheral)
                    }
                }
            }
            
            
        }
    }
    
    func loadDeviceName(_ peripheral: CBPeripheral) -> String {
        let connectedName = peripheral.identifier.uuidString
        return UserDefaults.standard.string(forKey: connectedName) ?? peripheral.name ?? "Unknown Device"
    }
    
    func loadPeripheralList() {
        let userDefaults = UserDefaults.standard
        if let storedPeripherals = userDefaults.dictionary(forKey: "PeripheralList") as? [String: [String:String]] {
            peripheralList = storedPeripherals
        }
    }
        
    func findName(for uuidString: String) -> String? {
        return peripheralList[uuidString]?["name"]
    }
    
    

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 연결 성공 처리
        print("연결 성공: \(peripheral.name ?? "")")
        peripheral.delegate = self
        pendingPeripheral = nil
        connectedPeripheral = peripheral
        connectedDeviceName = peripheral.name ?? "Unknown Device"
        connectedDeviceIdentifier = peripheral.identifier.uuidString
        isConnected = true
        
        peripheral.discoverServices(nil)
        delegate?.serialDidConnectPeripheral(peripheral: peripheral)
        DispatchQueue.main.async {
            self.isConnected = true
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Device disconnected.")
        isConnected = false
        if peripheral == connectedPeripheral {
            connectedPeripheral = nil
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        // 연결 실패 처리
        print("연결 실패: \(peripheral.name ?? ""), 오류: \(error?.localizedDescription ?? "알 수 없는 오류")")
    }
    
    // service 검색에 성공 시 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            // 검색된 모든 service에 대해서 characteristic을 검색합니다. 파라미터를 nil로 설정하면 해당 service의 모든 characteristic을 검색합니다.
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    // characteristic 검색에 성공 시 호출되는 메서드입니다.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
                return
            }
            
            for characteristic in characteristics {
                if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                
                if characteristic.properties.contains(.write) {
                    self.characteristic = characteristic
                    sendCurrentStatusRequest() // characteristic이 설정된 후 현재 상태를 요청합니다.
                }
                
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                
                if characteristic.uuid == characteristicUUID {
                    // 데이터를 보내기 위한 characteristic을 저장.
                    writeCharacteristic = characteristic
                    // 데이터를 보내는 타입을 설정합니다. 이는 주변기기가 어떤 type으로 설정되어 있는지에 따라 변경.
                    writeType = characteristic.properties.contains(.write) ? .withResponse : .withoutResponse
                    // 주변 기기와 연결 완료 시 동작하는 코드를 여기에 작성합니다.
                    delegate?.serialDidConnectPeripheral(peripheral: peripheral)
                }
            }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
            if error != nil {
                print("Failed to subscribe to characteristic notifications: \(String(describing: error))")
                return
            }
            if characteristic.isNotifying {
                print("Successfully subscribed to characteristic notifications.")
            } else {
                print("Stopped subscribing to characteristic notifications.")
            }
        }
    
    
    func sendCurrentStatusRequest() {
        guard let characteristic = self.characteristic else {
            print("Characteristic is not set.")
            return
        }
        
            let stx: UInt8 = 0x00
            let mode: UInt8 = 0x00
            let day: UInt8 = 0x00
            let onTime: [UInt8] = [0x00, 0x00]
            let offTime: [UInt8] = [0x00, 0x00]
            let onTime2: [UInt8] = [0x00, 0x00]
            let offTime2: [UInt8] = [0x00, 0x00]

            let checksum: UInt8 = stx &+ mode &+ day &+ onTime[0] &+ onTime[1] &+ offTime[0] &+ offTime[1] &+ onTime2[0] &+ onTime2[1] &+ offTime2[0] &+ offTime2[1]
            let packet: [UInt8] = [stx, mode, day, onTime[0], onTime[1], offTime[0], offTime[1], onTime2[0], onTime2[1], offTime2[0], offTime2[1], checksum, 0x0D, 0x0A]

            let data = Data(packet)
            connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
        }
    
    // peripheral으로부터 데이터를 전송받으면 호출되는 메서드.
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        // 전송받은 데이터가 존재하는지 확인.
        if let data = characteristic.value {
            let response = [UInt8](data)
            if response[0] == 0xDF {
                let mode = response[1]
                _ = response[2]
                _ = UInt16(response[3]) << 8 | UInt16(response[4])
                _ = UInt16(response[5]) << 8 | UInt16(response[6])
                _ = UInt16(response[7]) << 8 | UInt16(response[8])
                _ = UInt16(response[9]) << 8 | UInt16(response[10])
                let checksum = response[11]
                
                var calculatedChecksum: UInt8 = 0xDF
                for i in 1..<11 {
                    calculatedChecksum = calculatedChecksum &+ response[i]
                }
                
                if calculatedChecksum == checksum {
                    // Process the response
                    _ = mode// BIT0 to BIT2: 1 ~ 6 MODE
                    let emergencyOperation = (mode & 0x08) != 0 // BIT3: 긴급 운전 ON(1)/OFF(0)
                    let powerOn = (mode & 0x10) != 0 // BIT4: POWER ON(1)/OFF(0)
                    _ = (mode & 0x20) != 0 // BIT5: 간판출력 ON(1)/OFF(0)
                    
                    DispatchQueue.main.async {
                        self.powerOn = powerOn
                    }
                    
                    DispatchQueue.main.async {
                        self.emergencyOn = emergencyOperation
                    }
//                    print("Mode: \(mode)")
//                    print("Emergency Operation: \(emergencyOperation)")
//                    print("Power On: \(powerOn)")
//                    print("Sign Output On: \(signOutputOn)")
//                    print("Day: \(day)")
//                    print("OnTime: \(onTime)")
//                    print("OffTime: \(offTime)")
//                    print("OnTime2: \(onTime2)")
//                    print("OffTime2: \(offTime2)")
                } else {
                    print("Checksum mismatch")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // writeType이 .withResponse일 때, 블루투스 기기로부터의 응답이 왔을 때 호출되는 메서드.
        // 필요한 로직을 작성.
        // 전송받은 데이터가 존재하는지 확인.
        if let data = characteristic.value {
            let response = [UInt8](data)
            if response[0] == 0xDF {
                let mode = response[1]
                let day = response[2]
                let onTime = UInt16(response[3]) << 8 | UInt16(response[4])
                let offTime = UInt16(response[5]) << 8 | UInt16(response[6])
                let onTime2 = UInt16(response[7]) << 8 | UInt16(response[8])
                let offTime2 = UInt16(response[9]) << 8 | UInt16(response[10])
                let checksum = response[11]
                
                var calculatedChecksum: UInt8 = 0xDF
                for i in 1..<11 {
                    calculatedChecksum = calculatedChecksum &+ response[i]
                }
                
                if calculatedChecksum == checksum {
                    let emergencyOperation = (mode & 0x08) != 0 // BIT3: 긴급 운전 ON(1)/OFF(0)
                    let powerOn = (mode & 0x10) != 0 // BIT4: POWER ON(1)/OFF(0)
                    let signOutputOn = (mode & 0x20) != 0 // BIT5: 간판출력 ON(1)/OFF(0)
                    
                    DispatchQueue.main.async {
                        self.powerOn = powerOn
                    }
                    
                    DispatchQueue.main.async {
                        self.emergencyOn = emergencyOperation
                    }

                    print("Mode: \(mode)")
                    print("Emergency Operation: \(emergencyOperation)")
                    print("Power On: \(powerOn)")
                    print("Sign Output On: \(signOutputOn)")
                    print("Day: \(day)")
                    print("OnTime: \(onTime)")
                    print("OffTime: \(offTime)")
                    print("OnTime2: \(onTime2)")
                    print("OffTime2: \(offTime2)")
                } else {
                    print("Checksum mismatch")
                }
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        // 블루투스 기기의 신호 강도를 요청하는 peripheral.readRSSI()가 호출하는 메서드.
        // 신호 강도와 관련된 코드를 작성.
        // 필요한 로직을 작성.
    }
}

