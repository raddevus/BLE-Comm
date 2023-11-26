//
//  TestView.swift
//  BLE-Comm
//
//  Created by roger deutsch on 11/14/23.
//

import SwiftUI

struct TestView: View {
    var colors = ["Red", "Green", "Blue", "Tartan"]
    @State private var selectedColor = "Red"

    var body: some View {
        VStack {
            Picker("Please choose a color", selection: $selectedColor) {
                ForEach(colors, id: \.self) {
                    Text($0)
                }
            }
            Text("You selected: \(selectedColor)")
        }
    }
}

#Preview {
    TestView()
}
