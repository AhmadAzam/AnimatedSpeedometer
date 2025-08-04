//
//  SpeedometerView.swift
//  AnimatedSpeedometer
//
//  Created by Ahmad Azam on 03/08/2025.
//

import SwiftUI

struct SpeedometerView: View {
    @State private var speedometerValue: Double = 0
    @State private var inputText: String = ""
    @StateObject private var animationManager = SpeedometerAnimationManager(animationDuration: SpeedometerConfiguration.defaultAnimationDuration)
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    Text("Speedometer")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .padding(.top)
                    
                    Speedometer(
                        value: $speedometerValue,
                        animationManager: animationManager
                    )
                    .padding(.horizontal, 20)
                    
                    // Input section
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Enter Speed Value")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            TextField("Enter number(e.g., 5000, 150000)", text: $inputText)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .font(.system(.body, design: .monospaced))
                                .disabled(animationManager.isAnimating)
                                .onSubmit {
                                    submitValue()
                                }
                        }
                        
                        // Submit button
                        Button(action: submitValue) {
                            HStack {
                                if animationManager.isAnimating {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "speedometer")
                                }
                                
                                Text(animationManager.isAnimating ? "Animating..." : "Set Speed")
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isValidInput ? .brandClr : .gray)
                            )
                            .foregroundColor(.white)
                            .scaleEffect(animationManager.isAnimating ? 0.95 : 1.0)
                        }
                        .disabled(!isValidInput || animationManager.isAnimating)
                        .animation(.easeInOut(duration: 0.1), value: animationManager.isAnimating)
                       
                    }
                    .padding(.horizontal, 24)
                    Spacer(minLength: 50)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(.regularMaterial)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private var isValidInput: Bool {
        return SpeedometerInputValidator.isValidInput(inputText)
    }
    
    private func submitValue() {
        guard let inputValue = SpeedometerInputValidator.parseValue(from: inputText) else {
            return
        }
        
        hideKeyboard()
        
        animationManager.animateToValue(inputValue) { value in
            self.speedometerValue = value
        }
    }
}

// Helper extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SpeedometerView()
}
