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
    @State private var password = ""
    @State private var showPasswordError = false
    @State private var isLevel1Unlocked = false
    
    private let correctPassword = "1234" // You can change this to your desired password
    
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
                    VStack(spacing: 15) {
                        Text("Basic Level")
                            .font(.title3)
                            .padding()
                        
                        if !isLevel1Unlocked {
                            SecureField("Enter Password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            
                            Button(action: {
                                if password == correctPassword {
                                    isLevel1Unlocked = true
                                    showPasswordError = false
                                } else {
                                    showPasswordError = true
                                }
                            }) {
                                Text("Submit")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            if showPasswordError {
                                Text("Incorrect password. Please try again.")
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        } else {
                            Text("Level 1 Unlocked!")
                                .foregroundColor(.green)
                                .font(.headline)
                                .padding()
                        }
                    }
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
