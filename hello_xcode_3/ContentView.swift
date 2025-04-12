//
//  ContentView.swift
//  hello_xcode_3
//
//  Created by Ray_Chen on 2025/4/10.
//aaa

import SwiftUI

struct ContentView: View {
    @State private var isGameStarted = false
    @State private var currentLevel = 1
    @State private var password = ""
    @State private var showPasswordError = false
    @State private var unlockedLevels: Set<Int> = []
    @State private var showingVolumeMeter = false
    @State private var showingARView = false
    @State private var showingNFCReader = false
    @State private var isLevel2Complete = false
    
    private let correctPassword = "1234" // You can change this to your desired password
    
    var body: some View {
        ZStack {
            // Background gradient - using init(red:green:blue:opacity:) instead of .opacity()
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0, green: 0, blue: 1, opacity: 0.6),
                Color(red: 0.5, green: 0, blue: 0.5, opacity: 0.6)
            ]), 
                          startPoint: .topLeading, 
                          endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            if !isGameStarted {
                // Home Page
                VStack(spacing: 30) {
                    Text("Mind Puzzle")
                        .font(.system(size: 46, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    
                    Text("Test your problem-solving skills")
                        .font(.title3)
                        .foregroundColor(Color(white: 1, opacity: 0.8))
                    
                    Button(action: {
                        withAnimation {
                            isGameStarted = true
                        }
                    }) {
                        Text("Start")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.blue)
                                    .shadow(radius: 10)
                            )
                    }
                }
            } else {
                // Level View
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: {
                            withAnimation {
                                isGameStarted = false
                                showingVolumeMeter = false
                                showingARView = false
                                showingNFCReader = false
                            }
                        }) {
                            Image(systemName: "house.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        .padding()
                        
                        Spacer()
                        
                        Text("Level \(currentLevel)")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Empty view for symmetry
                        Image(systemName: "house.fill")
                            .font(.title2)
                            .foregroundColor(.clear)
                            .padding()
                    }
                    
                    Spacer()
                    
                    // Level Content
                    if currentLevel == 1 {
                        Level1View(
                            password: $password,
                            showPasswordError: $showPasswordError,
                            isLevelComplete: unlockedLevels.contains(1),
                            onSubmit: {
                                if password == correctPassword {
                                    withAnimation {
                                        _ = unlockedLevels.insert(1)
                                        showPasswordError = false
                                    }
                                } else {
                                    showPasswordError = true
                                }
                            }
                        )
                    } else if currentLevel == 2 {
                        VStack {
                            if isLevel2Complete {
                                VStack(spacing: 20) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.green)
                                    
                                    Text("Level 2 Complete!")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                }
                            } else {
                               
                                
                                VolumeLevelView(onSuccess: {
                                    withAnimation {
                                        isLevel2Complete = true
                                        _ = unlockedLevels.insert(2)
                                    }
                                })
                                .frame(height: 300)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(white: 1, opacity: 0.15))
                                .shadow(radius: 10)
                        )
                        .padding()
                    } else if currentLevel == 3 {
                        VStack {
                          
                            Button(action: {
                                showingARView = true
                            }) {
                                HStack {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.title2)
                                    Text("Launch AR Scanner")
                                }
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.blue)
                                        .shadow(radius: 5)
                                )
                            }
                            .padding()
                            
                         
                            
                            Button(action: {
                                showingNFCReader = true
                            }) {
                                HStack {
                                    Image(systemName: "radiowaves.left")
                                        .font(.title2)
                                    Text("Launch NFC Scanner")
                                }
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.blue)
                                        .shadow(radius: 5)
                                )
                            }
                            .padding()
                            
                            // This is for demo purposes - in a real app, completion would come from the AR view
                            Button(action: {
                                withAnimation {
                                    _ = unlockedLevels.insert(3)
                                }
                            }) {
                                Text("Simulate Success")
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(red: 0, green: 0.8, blue: 0, opacity: 0.6))
                                    )
                            }
                            
                            if unlockedLevels.contains(3) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                    .padding()
                                
                                Text("Level 3 Complete!")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(white: 1, opacity: 0.15))
                                .shadow(radius: 10)
                        )
                        .padding()
                        .sheet(isPresented: $showingARView) {
                            WaterBottleARView()
                        }
                        .sheet(isPresented: $showingNFCReader) {
                            NFCReader()
                        }
                    } else if currentLevel == 4 {
                        VStack {
                           
                            
                            Button(action: {
                                showingNFCReader = true
                            }) {
                                HStack {
                                    Image(systemName: "radiowaves.left")
                                        .font(.title2)
                                    Text("Launch NFC Scanner")
                                }
                                .foregroundColor(.white)
                                .frame(width: 250, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.blue)
                                        .shadow(radius: 5)
                                )
                            }
                            .padding()
                            
                            // This is for demo purposes - in a real app, completion would come from the NFC reader
                            Button(action: {
                                withAnimation {
                                    _ = unlockedLevels.insert(4)
                                }
                            }) {
                                Text("Simulate Success")
                                    .foregroundColor(.white)
                                    .frame(width: 200, height: 40)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(red: 0, green: 0.8, blue: 0, opacity: 0.6))
                                    )
                            }
                            
                            if unlockedLevels.contains(4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                    .padding()
                                
                                Text("Level 4 Complete!")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                
                                Text("Congratulations! You've completed all levels!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(white: 1, opacity: 0.15))
                                .shadow(radius: 10)
                        )
                        .padding()
                        .sheet(isPresented: $showingNFCReader) {
                            NFCReader()
                        }
                    }
                    
                    Spacer()
                    
                    // Navigation buttons
                    if unlockedLevels.contains(currentLevel) && currentLevel < 4 {
                        Button(action: {
                            withAnimation {
                                currentLevel += 1
                                if currentLevel == 2 {
                                    showingVolumeMeter = true
                                }
                            }
                        }) {
                            Text("Next Level")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.green)
                                        .shadow(radius: 5)
                                )
                        }
                        .padding()
                    } else if unlockedLevels.contains(4) && currentLevel == 4 {
                        Button(action: {
                            withAnimation {
                                isGameStarted = false
                            }
                        }) {
                            Text("Back to Home")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.purple)
                                        .shadow(radius: 5)
                                )
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct Level1View: View {
    @Binding var password: String
    @Binding var showPasswordError: Bool
    let isLevelComplete: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if !isLevelComplete {
                Text("Enter the secret code")
                    .font(.title2)
                    .foregroundColor(.white)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .padding()
                
                Button(action: onSubmit) {
                    Text("Submit")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 150, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color.blue)
                                .shadow(radius: 5)
                        )
                }
                
                if showPasswordError {
                    Text("Incorrect password. Try again!")
                        .foregroundColor(.red)
                        .padding()
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Level Complete!")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(white: 1, opacity: 0.15))
                .shadow(radius: 10)
        )
        .padding()
    }
}

#Preview {
    ContentView()
}
