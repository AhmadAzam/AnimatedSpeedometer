//
//  SpeedometerFormatter.swift
//  AnimatedSpeedometer
//
//  Created by Ahmad Azam on 03/08/2025.
//

import Foundation

struct SpeedometerFormatter {
    
    // MARK: - Public Methods
    
    /// Formats a value for display on the speedometer (center text)
    static func formatDisplayValue(_ value: Double) -> String {
        if value > 100_000 {
            return String(format: "%.0fk+", value / 1000)
        } else if value >= 1000 {
            let thousands = value / 1000
            // Check if the decimal part is essentially zero
            if thousands.truncatingRemainder(dividingBy: 1) < 0.1 {
                return String(format: "%.0fk", thousands)
            } else {
                return String(format: "%.1fk", thousands)
            }
        } else {
            // For values less than 1000, check if it has meaningful decimal places
            if value.truncatingRemainder(dividingBy: 1) < 0.1 {
                return String(format: "%.0f", value)
            } else {
                return String(format: "%.1f", value)
            }
        }
    }
    
    /// Formats a value for scale markings around the dial
    static func formatScaleValue(_ value: Double) -> String {
        switch value {
        case 100_000...:
            return "100k+"
        case 1000...:
            return "\(Int(value / 1000))k"
        default:
            return "\(Int(value))"
        }
    }
}
