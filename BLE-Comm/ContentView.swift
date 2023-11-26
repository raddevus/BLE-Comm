//
//  ContentView.swift
//  BLE-Comm
//
//  Created by roger deutsch on 11/12/23.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject private var gameTowerVM = GameTowerViewModel()
    @State private var connectionBtnText = "Connect"
    @State private var charCount = 0
    @State private var pickerVal :String = ""
    
    @State private var dataToSend = ""
    
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
                            gameTowerVM.connect()}
                        else{
                            connectionBtnText = "Connect"
                            gameTowerVM.disconnect()
                        }
                        
                    }.buttonStyle(.bordered)
                }
                TextField("Current state: ", text:$gameTowerVM.connectionStateText)
                Picker("Chars", selection: $charCount){
                    
                    ForEach (gameTowerVM.allCharacteristics.indices, id: \.self)
                    {
                        Text(gameTowerVM.allCharacteristics[$0])
                    }
                    
                }
                Picker("istics", selection: $pickerVal){
                    ForEach(gameTowerVM.allCharacteristics, id:\.self){
                        Text($0)
                    }
                }
                HStack{
                    TextField("text to send",text:$dataToSend )
                    
                    Button("Send"){
                        gameTowerVM.sendData(data: dataToSend)
                        //dataToSend = ""
                        
                    }.buttonStyle(.bordered)
                }
            }
            .padding()
            .tabItem{
                Label("Main", systemImage:"star")
            }.tag("main")
            VStack{
                Text("tab 2")
            }.tabItem{
                Label("Config", systemImage:"circle")
            }.tag("config")
        }
    }
}

#Preview {
    ContentView()
}
