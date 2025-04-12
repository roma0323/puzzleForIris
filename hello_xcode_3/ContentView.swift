//
//  ContentView.swift
//  hello_xcode_3
//
//  Created by Ray_Chen on 2025/4/10.
//aaa

import SwiftUI

struct ContentView: View {
    @State private var selectedLevel = 1
    @State private var showingVolumeMeter = false
    @State private var showingARView = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Level")
                    .font(.largeTitle)
                    .padding()
                
                ForEach(1...3, id: \.self) { level in
                    Button(action: {
                        selectedLevel = level
                        if level == 2 {
                            showingVolumeMeter = true
                        } else if level == 3 {
                            showingARView = true
                        }
                    }) {
                        Text("Level \(level)")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selectedLevel == level ? Color.blue : Color.gray)
                            )
                    }
                    .padding(.horizontal)
                }
                
                if selectedLevel == 1 {
                    Text("Basic Level")
                        .font(.title3)
                        .padding()
                } else if selectedLevel == 2 {
                    Text("Volume Meter Level")
                        .font(.title3)
                        .padding()
                } else if selectedLevel == 3 {
                    Text("AR Water Bottle Scanner")
                        .font(.title3)
                        .padding()
                }
            }
            .sheet(isPresented: $showingVolumeMeter) {
                VolumeLevelView()
            }
            .fullScreenCover(isPresented: $showingARView) {
                WaterBottleARView()
            }
        }
    }
}

#Preview {
    ContentView()
}
