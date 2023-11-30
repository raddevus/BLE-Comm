//
//  GameTowerViewModel.swift
//  BLE-Comm
//
//  Created by roger deutsch on 11/12/23.
//

import Foundation
import CoreBluetooth

class GameTowerViewModel : NSObject, ObservableObject, Identifiable{
    var id = UUID()
    
    @Published var connectionStateText = "Disconnected"
    @Published var connectionState = false;
    private let serviceUUID = CBUUID(string:"EBC0FCC1-2FC3-44B7-94A8-A08D0A0A5079")
    private var centralManager: CBCentralManager?
    private var connectedPeripheral: CBPeripheral?
    private var centralQueue: DispatchQueue?
    @Published var allCharacteristics : [String] = ["super", "ugly", "yikes"]
    private var inputCharacteristic : CBCharacteristic? = nil
    private var setConnState: ((Bool) ->())? = nil
    
    func changeConnectionState(){
        connectionState = !connectionState
        if (connectionState){
            connectionStateText = "Connected"
            return
        }
        connectionStateText = "Disconnected"
        
    }
    
    func connect(_ setBleConnState: @escaping (Bool)->()) async {
        connectionState = true
        setConnState = setBleConnState
        DispatchQueue.main.async{
            self.connectionStateText = "Connecting..."
        }
        centralQueue = DispatchQueue(label: "test.discovery")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func disconnect(){
        guard let manager = centralManager,
              let peripheral = connectedPeripheral else {return}
        print("DISCONNECTING ....----->")
        manager.cancelPeripheralConnection(peripheral)
        connectionState = false
        DispatchQueue.main.async{
            self.connectionStateText = "disconnected"
        }
    }
    
    func sendData(data: String) async {
        let sendMsg = data.data(using: String.Encoding.utf8)
        print("sending data: \(data)")
        print("input char is: \(inputCharacteristic?.uuid.uuidString ?? "NOPE!")")
        
        connectedPeripheral?.writeValue(sendMsg ?? Data(), for: inputCharacteristic!, type: .withoutResponse)
    }
    
    func sendDataAndDisconnect(data: String){
        let sendMsg = data.data(using: String.Encoding.ascii)
        print("sending data: \(data)")
        connectedPeripheral?.writeValue(sendMsg ?? Data(), for: inputCharacteristic!, type: .withoutResponse)
        disconnect()
    }
    
}

extension GameTowerViewModel: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            DispatchQueue.main.async{
                self.connectionStateText = "Scanning..."
            }
            // if you use nil instead of serviceUUID then this the scan will
            // scan all available peripherals (within distance)
            central.scanForPeripherals(withServices: [serviceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async{
            print("Discovered \(peripheral.name ?? "UNKNOWN")")
        }
        //central.stopScan()
        connectedPeripheral = peripheral
        central.connect(peripheral, options:nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(peripheral.name ?? "UNKNOWN")")
        centralManager = nil
    }
}

extension GameTowerViewModel : CBPeripheralDelegate{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        DispatchQueue.main.async{
            self.connectionStateText = "Discovered services for \(peripheral.name ?? "UNKNOWN")"
        }
        guard let services = peripheral.services else{
            return
        }
        for service in services{
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else{
            return
        }
        for ch in characteristics{
            if ch.uuid.uuidString == "622B2C55-7914-4140-B85B-879C5E252DA0"{
                print("gotcha!!!")
                inputCharacteristic = ch
                print("got it! \(ch.uuid.uuidString)")
                setConnState!(true)
                return
            }
            print("char \(ch.uuid.uuidString)")
//            DispatchQueue.main.async{
//                self.allCharacteristics.append(ch.uuid.uuidString)
//            }
        }
    }
    
}
