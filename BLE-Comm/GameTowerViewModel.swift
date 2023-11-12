//
//  GameTowerViewModel.swift
//  BLE-Comm
//
//  Created by roger deutsch on 11/12/23.
//

import Foundation

class GameTowerViewModel : NSObject, ObservableObject, Identifiable{
    var id = UUID()
    
    @Published var connectionStateText = "Disconnected"
    @Published var connectionState = false;
    
    func changeConnectionState(){
        connectionState = !connectionState
        if (connectionState){
            connectionStateText = "Connected"
            return
        }
        connectionStateText = "Disconnected"
        
    }
    
}
