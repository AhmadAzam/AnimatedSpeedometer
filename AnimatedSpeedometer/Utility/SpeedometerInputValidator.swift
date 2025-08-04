//
//  SpeedometerInputValidator.swift
//  AnimatedSpeedometer
//
//  Created by Ahmad Azam on 03/08/2025.
//

import Foundation

/// Handles input validation for speedometer values
struct SpeedometerInputValidator {
    
    // MARK: - Public Methods
    
    /// Validates and parses input text to a Double value
    /// - Parameter input: The text input to validate
    /// - Returns: Optional Double if valid, nil if invalid
    static func parseValue(from input: String) -> Double? {
        let trimmedInput = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let value = Double(trimmedInput), value >= 0 else {
            return nil
        }
        return value
    }
    
    /// Checks if the input text represents a valid speedometer value
    /// - Parameter input: The text input to validate
    /// - Returns: True if valid, false otherwise
    static func isValidInput(_ input: String) -> Bool {
        return parseValue(from: input) != nil
    }
}