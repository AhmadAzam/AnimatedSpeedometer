//
//  SpeedometerAnimationManager.swift
//  AnimatedSpeedometer
//
//  Created by Ahmad Azam on 03/08/2025.
//

import SwiftUI
import UIKit

/// Manages all animation and haptic feedback for the speedometer
class SpeedometerAnimationManager: ObservableObject {
    @Published var isAnimating = false
    
    private let animationDuration: TimeInterval
    private var hapticTimer: Timer?
    
    init(animationDuration: TimeInterval = SpeedometerConfiguration.defaultAnimationDuration) {
        self.animationDuration = animationDuration
    }
    
    deinit {
        stopRacingHaptics()
    }
    
    // MARK: - Public Methods
    
    /// Animates to a new value with racing-style animation and haptic feedback
    func animateToValue(_ targetValue: Double, onValueChange: @escaping (Double) -> Void) {
        // Start haptic feedback for racing feel
        startRacingHaptics()
        
        onValueChange(targetValue)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.stopRacingHaptics()
        }
    }
    
    /// Performs the startup sweep animation with bouncy haptics
    func performStartupSweep(onStateChange: @escaping (Double, Double) -> Void, onComplete: @escaping () -> Void) {
        isAnimating = true
        
        startBouncyHaptics()
        onStateChange(1.0, SpeedometerConfiguration.startAngle + SpeedometerConfiguration.totalAngle)
        
        // Then sweep back to zero after a brief pause
        DispatchQueue.main.asyncAfter(deadline: .now() + SpeedometerConfiguration.defaultSweepPause) {
            onStateChange(0.0, SpeedometerConfiguration.startAngle)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.stopBouncyHaptics()
                self.isAnimating = false
                onComplete()
            }
        }
    }
    
    
    /// Starts continuous racing haptic feedback during normal animations
    private func startRacingHaptics() {
        stopRacingHaptics() // Stop any existing haptics first
        isAnimating = true
        
        // Create a timer for continuous haptic pulses
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred(intensity: 0.7)
        }
    }
    
    /// Starts bouncy haptic feedback for startup sweep
    private func startBouncyHaptics() {
        stopRacingHaptics() // Stop any existing haptics first
        isAnimating = true
        
        // Create a timer for bouncy haptic pulses (faster for startup effect)
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 0.09, repeats: true) { _ in
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred(intensity: 0.5)
        }
    }
    
    /// Stops haptic feedback for bouncy animations
    private func stopBouncyHaptics() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
    
    /// Stops racing haptic feedback
    private func stopRacingHaptics() {
        hapticTimer?.invalidate()
        hapticTimer = nil
        isAnimating = false
    }
}
