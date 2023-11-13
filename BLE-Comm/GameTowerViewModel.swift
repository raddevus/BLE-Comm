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
    
    func changeConnectionState(){
        connectionState = !connectionState
        if (connectionState){
            connectionStateText = "Connected"
            return
        }
        connectionStateText = "Disconnected"
        
    }
    
    func connect(){
        connectionState = true
        DispatchQueue.main.async{
            self.connectionStateText = "Connecting..."
        }
        centralQueue = DispatchQueue(label: "test.discovery")
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func disconnect(){
        guard let manager = centralManager,
              let peripheral = connectedPeripheral else {return}
        manager.cancelPeripheralConnection(peripheral)
        connectionState = false
        DispatchQueue.main.async{
            self.connectionStateText = "disconnected"
        }
    }
    
}

extension GameTowerViewModel: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn){
            DispatchQueue.main.async{
                self.connectionStateText = "Scanning..."
            }
            central.scanForPeripherals(withServices: [serviceUUID])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async{
            self.connectionStateText = "Discovered \(peripheral.name ?? "UNKNOWN")"
        }
        central.stopScan()
        connectedPeripheral = peripheral
        central.connect(peripheral, options:nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
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
            print("char \(ch.uuid.uuidString)")
            DispatchQueue.main.async{
                self.allCharacteristics.append(ch.uuid.uuidString)
            }
        }
    }
    
}
