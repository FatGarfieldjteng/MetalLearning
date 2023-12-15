//
//  ContentView.swift
//  MetalLearning
//
//  Created by Tengjun on 12/15/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            VStack{
                MetalView().border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
                Text("Hello, Metal")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
