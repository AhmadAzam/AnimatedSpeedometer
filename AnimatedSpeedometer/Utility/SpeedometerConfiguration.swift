//
//  SpeedometerConfiguration.swift
//  AnimatedSpeedometer
//
//  Created by Ahmad Azam on 03/08/2025.
//

import Foundation

struct SpeedometerConfiguration {
    
    // MARK: - Angular Configuration
    static let startAngle: Double = 161.04 // Bottom left in degrees
    static let totalAngle: Double = 217.92 // Total sweep in degrees
    
    // MARK: - Scale Configuration
    static let scaleBreakpoints: [Double] = [0, 1000, 5000, 10000, 25000, 50000, 100000]
    
    // MARK: - Size Ratios (relative to canvas size)
    static let speedometerBackgroundRatio: CGFloat = 0.95
    static let radiusRatio: CGFloat = 0.475
    static let progressTrackOffsetRatio: CGFloat = 0.0125
    static let progressTrackWidthRatio: CGFloat = 0.025
    static let hubSizeRatio: CGFloat = 0.15
    static let needleLengthRatio: CGFloat = 0.70
    static let needleWidthRatio: CGFloat = 0.012
    static let textPaddingRatio: CGFloat = 0.19
    static let scaleTextSizeRatio: CGFloat = 0.04
    
    // MARK: - Spacing
    static let scaleLabelSpacing: CGFloat = 18
    
    // MARK: - Default Values
    static let defaultMaxValue: Double = 100_000
    static let defaultAnimationDuration: TimeInterval = 1.5
    static let defaultSweepPause: TimeInterval = 0.9
}
