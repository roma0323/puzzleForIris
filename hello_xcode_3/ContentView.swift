//
//  ContentView.swift
//  hello_xcode_3
//
//  Created by Ray_Chen on 2025/4/10.
//

import SwiftUI

struct ContentView: View {
    @State private var password = ""
    @State private var isPasswordCorrect = false
    @State private var showError = false
    @State private var isUnlocked = false
    
    private let correctPassword = "0418"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isUnlocked {
                    NavigationLink(destination: VolumeLevelView()) {
                        Text("Start Volume Challenge")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                } else {
                    Text("Enter Password")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .autocapitalization(.none)
                    
                    Button(action: verifyPassword) {
                        Text("Submit")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if showError {
                        Text("Incorrect password. Please try again.")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
            .padding()
            .navigationTitle("Puzzle System")
        }
    }
    
    private func verifyPassword() {
        if password == correctPassword {
            isUnlocked = true
            showError = false
        } else {
            showError = true
            password = ""
        }
    }
}

#Preview {
    ContentView()
}
