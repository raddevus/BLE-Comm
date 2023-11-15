//
//  ContentView.swift
//  BLE-Comm
//
//  Created by roger deutsch on 11/12/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var gameTowerVM = GameTowerViewModel()
    
    @State private var userName = ""
    
    @State private var connectionBtnText = "Connect"
    @State private var charCount = 0
    
    @State private var dataToSend = ""
    
    init(){
        print ("in init...")
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\(userName)")
            Text("\(gameTowerVM.connectionStateText)")
            HStack{
                Button("Set User"){
                    userName = "Frank - "
                    gameTowerVM.changeConnectionState()
                }
                Button(connectionBtnText){
                    if (gameTowerVM.connectionState == false){
                        connectionBtnText = "Disconnect"
                        gameTowerVM.connect()}
                    else{
                        connectionBtnText = "Connect"
                        gameTowerVM.disconnect()
                    }
                    
                }
            }
            TextField("Current state: ", text:$gameTowerVM.connectionStateText)
            Picker("Chars", selection: $charCount){
                
                ForEach (gameTowerVM.allCharacteristics.indices, id: \.self)
                {
                    Text(gameTowerVM.allCharacteristics[$0])
                }
            }
            HStack{
                TextField("text to send",text:$dataToSend )

                Button("Send"){
                    gameTowerVM.sendData(data: dataToSend)
                    //dataToSend = ""
                    
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
