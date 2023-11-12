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
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("\(userName)")
            Text("\(gameTowerVM.connectionStateText)")
            Button("Set User"){
                userName = "Frank - "
                gameTowerVM.changeConnectionState()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
