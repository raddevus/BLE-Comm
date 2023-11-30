//
//  ContentView.swift
//  BLE-Comm
//
//  Created by roger deutsch on 11/12/23.
//

import SwiftUI

struct ContentView: View {

    @State private var gameTowerVM = GameTowerViewModel()
    @State private var connectionBtnText = "Connect"
    @State private var charCount = 0
    @State private var pickerVal :String = ""
    @State private var isBleConnected: Bool = false
    
    @State private var dataToSend = ""
    @State private var isSendAlertDisplayed = false
    
    func setBleConnectionState(_ isConnected: Bool){
        isBleConnected = isConnected
    }
    
    init(){
        print ("in init...")
        pickerVal = gameTowerVM.allCharacteristics[0]
        
    }
    
    var body: some View {
        TabView{
            
            VStack {
                Text("\(gameTowerVM.connectionStateText)")
                HStack{
                    Button(connectionBtnText){
                        if (gameTowerVM.connectionState == false){
                            connectionBtnText = "Disconnect"
                            Task{
                                await gameTowerVM.connect(setBleConnectionState)
                            }
                        }
                        else{
                            connectionBtnText = "Connect"
                            gameTowerVM.disconnect()
                        }
                        
                    }.buttonStyle(.bordered)
                }
                TextField("Current state: ", text:$gameTowerVM.connectionStateText)
//                Picker("Chars", selection: $charCount){
//                    
//                    ForEach (gameTowerVM.allCharacteristics.indices, id: \.self)
//                    {
//                        Text(gameTowerVM.allCharacteristics[$0])
//                    }
//                    
//                }
//                Picker("istics", selection: $pickerVal){
//                    ForEach(gameTowerVM.allCharacteristics, id:\.self){
//                        Text($0)
//                    }
//                }
                HStack{
                    TextField("text to send",text:$dataToSend )
                    
                    Button("Send"){
                        task{
                            await gameTowerVM.sendData(data: dataToSend)
                        }
                        
                        
                        //dataToSend = ""
                        
                    }.buttonStyle(.bordered)
                    
                }
            }
            .padding()
            .tabItem{
                Label("Main", systemImage:"star")
            }.tag("main")
            VStack{
                Button("Send Random"){
                    Task{
                        await gameTowerVM.connect(setBleConnectionState)
                        while(!isBleConnected){
                            Thread.sleep(forTimeInterval: 0.25)
                        }
                        await gameTowerVM.sendData(data: "what is up?! \(Date.now.formatted())")
                        
                    }
                        //isSendAlertDisplayed = true
                }
                .alert("Data send successful!", isPresented: $isSendAlertDisplayed){
                    Button("OK"){
                        isSendAlertDisplayed = false
                    }
                }
                Button("Disconnect"){
                    isBleConnected = false
                    gameTowerVM.disconnect()
                }.buttonStyle(.bordered)
            }.tabItem{
                Label("Config", systemImage:"circle")
            }.tag("config")
            
        }
        
    }
    
    func bleConnect(){
        
            if (gameTowerVM.connectionState){
                return
            }
            else{
                print("in ELSE...")
                Task{
                    await gameTowerVM.connect(setBleConnectionState)
                }
            }
        }
   
}

#Preview {
    ContentView()
}
