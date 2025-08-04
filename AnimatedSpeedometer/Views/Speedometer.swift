//
//  Speedometer.swift
//  AnimatedSpeedometer
//
//  Created by Ahmad Azam on 03/08/2025.
//

import SwiftUI

struct Speedometer: View {
    @Binding var value: Double
    let maxValue: Double
    let animationDuration: TimeInterval
    
    @State private var needleAngle: Double = SpeedometerConfiguration.startAngle
    @State private var progressAmount: Double = 0
    @State private var currentCanvasSize: CGFloat = 0
    @State private var hasPerformedStartupSweep = false
    @State private var displayedValue: Double = 0
    
    @ObservedObject var animationManager: SpeedometerAnimationManager
    
    
    init(value: Binding<Double>,
         maxValue: Double = SpeedometerConfiguration.defaultMaxValue,
         animationDuration: TimeInterval = SpeedometerConfiguration.defaultAnimationDuration,
         animationManager: SpeedometerAnimationManager) {
        self._value = value
        self.maxValue = maxValue
        self.animationDuration = animationDuration
        self.animationManager = animationManager
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let radius = size * SpeedometerConfiguration.radiusRatio
            let progressRadius = radius + size * SpeedometerConfiguration.progressTrackOffsetRatio
            
            ZStack {
                Canvas { context, canvasSize in
                    let canvasCenter = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
                    let canvasMinSize = min(canvasSize.width, canvasSize.height)
                    let canvasRadius = canvasMinSize * SpeedometerConfiguration.radiusRatio
                    let canvasProgressRadius = canvasRadius + canvasMinSize * SpeedometerConfiguration.progressTrackOffsetRatio
                    
                    DispatchQueue.main.async {
                        self.currentCanvasSize = canvasSize.height
                    }
                    
                    // Draw static elements
                    drawSpeedometerBackground(context: context, center: canvasCenter, size: canvasMinSize)
                    drawProgressTrack(context: context, center: canvasCenter, radius: canvasProgressRadius, size: canvasMinSize)
                    drawScaleMarkings(context: context, center: canvasCenter, radius: canvasRadius, size: canvasMinSize)
                    drawCenterHub(context: context, center: canvasCenter, size: canvasMinSize)
                }
                
                // Animated Progress Arc
                ProgressArcShape(
                    progressAmount: progressAmount,
                    radius: progressRadius,
                    lineWidth: size * SpeedometerConfiguration.progressTrackWidthRatio
                )
                .stroke(Color.progressArcBg, style: StrokeStyle(lineWidth: size * SpeedometerConfiguration.progressTrackWidthRatio, lineCap: .round))
                
                // Animated Needle
                NeedleShape(
                    angle: needleAngle,
                    length: radius * SpeedometerConfiguration.needleLengthRatio,
                    width: size * SpeedometerConfiguration.needleWidthRatio
                )
                .stroke(Color.needleBg, style: StrokeStyle(lineWidth: size * SpeedometerConfiguration.needleWidthRatio, lineCap: .round))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(alignment: .bottom) {
            // Value display overlay
            Text(SpeedometerFormatter.formatDisplayValue(displayedValue))
                .font(.system(.title2, design: .rounded).weight(.medium))
                .foregroundStyle(.meterReadingClr)
                .multilineTextAlignment(.center)
                .contentTransition(.numericText())
                .padding(.bottom, dynamicTextPadding)
        }
        .onChange(of: value) { _, newValue in
            updateSpeedometer(to: newValue)
        }
        .onAppear {
            displayedValue = value
            if !hasPerformedStartupSweep {
                performStartupSweep()
            } else {
                updateSpeedometer(to: value)
            }
        }
    }
    
    private var dynamicTextPadding: CGFloat {
        return currentCanvasSize * SpeedometerConfiguration.textPaddingRatio
    }
    
    private func performStartupSweep() {
        hasPerformedStartupSweep = true
        displayedValue = 0 // Start from zero for startup sweep
        
        animationManager.performStartupSweep(
            onStateChange: { progressAmount, needleAngle in
                // Calculate display value based on progress
                let sweepValue = progressAmount * self.maxValue
                
                withAnimation(.interpolatingSpring(stiffness: 150, damping: 30)) {
                    self.progressAmount = progressAmount
                    self.needleAngle = needleAngle
                    self.displayedValue = sweepValue
                }
            },
            onComplete: {
                self.updateSpeedometer(to: self.value)
            }
        )
    }
    
    // MARK: - Canvas Drawing Functions
    
    private func drawSpeedometerBackground(context: GraphicsContext, center: CGPoint, size: CGFloat) {
        let circleSize = size * SpeedometerConfiguration.speedometerBackgroundRatio
        let backgroundRect = CGRect(
            x: center.x - circleSize / 2,
            y: center.y - circleSize / 2,
            width: circleSize,
            height: circleSize
        )
        let backgroundPath = Path(ellipseIn: backgroundRect)
        
        let gradient = Gradient(colors: [.meterBgGradient1, .meterBgGradient2])
        let startPoint = CGPoint(x: center.x, y: center.y - circleSize / 2)
        let endPoint = CGPoint(x: center.x, y: center.y + circleSize / 2)
        
        context.fill(
            backgroundPath,
            with: .linearGradient(gradient, startPoint: startPoint, endPoint: endPoint)
        )
    }
    
    private func drawProgressTrack(context: GraphicsContext, center: CGPoint, radius: CGFloat, size: CGFloat) {
        let lineWidth = size * SpeedometerConfiguration.progressTrackWidthRatio
        
        let trackPath = createArcPath(
            center: center,
            radius: radius,
            startAngle: SpeedometerConfiguration.startAngle,
            endAngle: SpeedometerConfiguration.startAngle + 360
        )
        
        let gradient = Gradient(stops: [
            .init(color: .progressBgGradient1, location: 0.8),
            .init(color: .progressBgGradient2, location: 1.0)
        ])
        
        let shading = GraphicsContext.Shading.radialGradient(
            gradient,
            center: center,
            startRadius: 0,
            endRadius: radius
        )
        
        context.stroke(
            trackPath,
            with: shading,
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        )
    }
    
    
    private func drawProgressArc(context: GraphicsContext, center: CGPoint, radius: CGFloat, size: CGFloat) {
        let lineWidth = size * SpeedometerConfiguration.progressTrackWidthRatio
        let progressEndAngle = SpeedometerConfiguration.startAngle + (progressAmount * SpeedometerConfiguration.totalAngle)
        let progressPath = createArcPath(
            center: center,
            radius: radius,
            startAngle: SpeedometerConfiguration.startAngle,
            endAngle: progressEndAngle
        )
        
        context.stroke(
            progressPath,
            with: .color(.progressArcBg),
            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
        )
    }
    
    private func drawScaleMarkings(context: GraphicsContext, center: CGPoint, radius: CGFloat, size: CGFloat) {
        let progressTrackRadius = radius + size * SpeedometerConfiguration.progressTrackOffsetRatio
        let edgeRadius = progressTrackRadius - SpeedometerConfiguration.scaleLabelSpacing
        let breakpoints = SpeedometerConfiguration.scaleBreakpoints
        let count = breakpoints.count
        let middleIndex = count / 2
        let hasExactMiddle = count % 2 != 0
        
        for i in 0..<breakpoints.count {
            let angle = SpeedometerConfiguration.startAngle + (Double(i) * SpeedometerConfiguration.totalAngle / Double(breakpoints.count - 1))
            let angleRadians = angle * Double.pi / 180
            
            let labelValue = SpeedometerFormatter.formatScaleValue(breakpoints[i])
            let labelText = Text(labelValue)
                .font(.caption.weight(.semibold))
                .foregroundColor(.meterTextClr)
            
            // Calculate text bounds
            let font = UIFont.systemFont(ofSize: size * SpeedometerConfiguration.scaleTextSizeRatio, weight: .semibold)
            let textAttributes: [NSAttributedString.Key: Any] = [.font: font]
            let textSize = (labelValue as NSString).size(withAttributes: textAttributes)
            
            // Calculate edge position on the circle
            let edgePoint = CGPoint(
                x: center.x + edgeRadius * CGFloat(Darwin.cos(angleRadians)),
                y: center.y + edgeRadius * CGFloat(Darwin.sin(angleRadians))
            )
            
            // Determine label position based on side of speedometer
            let normalizedAngle = angle.truncatingRemainder(dividingBy: 360)
            let isLeftSide = normalizedAngle > 90 && normalizedAngle < 270
            let isMiddle = hasExactMiddle && (i == middleIndex)
            
            let labelCenter: CGPoint
            if isMiddle {
                labelCenter = edgePoint
            } else if isLeftSide {
                labelCenter = CGPoint(x: edgePoint.x + textSize.width / 2, y: edgePoint.y)
            } else {
                labelCenter = CGPoint(x: edgePoint.x - textSize.width / 2, y: edgePoint.y)
            }
            
            let labelSize = CGSize(width: textSize.width + 4, height: textSize.height + 2)
            let labelRect = CGRect(
                x: labelCenter.x - labelSize.width / 2,
                y: labelCenter.y - labelSize.height / 2,
                width: labelSize.width,
                height: labelSize.height
            )
            
            context.draw(labelText, in: labelRect)
        }
    }
    
    private func drawCenterHub(context: GraphicsContext, center: CGPoint, size: CGFloat) {
        let hubSize = size * SpeedometerConfiguration.hubSizeRatio
        let hubRect = CGRect(
            x: center.x - hubSize / 2,
            y: center.y - hubSize / 2,
            width: hubSize,
            height: hubSize
        )
        
        let hubPath = Path(ellipseIn: hubRect)
        context.fill(hubPath, with: .color(.hubBg))
    }
    
    private func drawNeedle(context: GraphicsContext, center: CGPoint, radius: CGFloat, size: CGFloat) {
        let needleLength = radius * SpeedometerConfiguration.needleLengthRatio
        let needleAngleRadians = needleAngle * Double.pi / 180
        
        let needleEnd = CGPoint(
            x: center.x + needleLength * CGFloat(Darwin.cos(needleAngleRadians)),
            y: center.y + needleLength * CGFloat(Darwin.sin(needleAngleRadians))
        )
        
        var needlePath = Path()
        needlePath.move(to: center)
        needlePath.addLine(to: needleEnd)
        
        context.stroke(
            needlePath,
            with: .color(.needleBg),
            style: StrokeStyle(lineWidth: size * SpeedometerConfiguration.needleWidthRatio, lineCap: .round)
        )
    }
    
    
    // MARK: - Helper Functions
    private func createArcPath(center: CGPoint, radius: CGFloat, startAngle: Double, endAngle: Double) -> Path {
        Path { path in
            path.addArc(
                center: center,
                radius: radius,
                startAngle: Angle(degrees: startAngle),
                endAngle: Angle(degrees: endAngle),
                clockwise: false
            )
        }
    }
    
    private func updateSpeedometer(to newValue: Double) {
        let clampedValue = min(newValue, maxValue)
        let segmentProgress = calculateNonLinearProgress(for: clampedValue)
        let targetAngle = SpeedometerConfiguration.startAngle + (segmentProgress * SpeedometerConfiguration.totalAngle)
        
        // Start counting animation for digital display using animation manager
        animationManager.animateCountingValue(from: displayedValue, to: newValue) { currentValue in
            self.displayedValue = currentValue
        }
        
        // Use animation manager to handle racing animation and haptics
        animationManager.animateToValue(newValue) { _ in
            // Racing-style animation with custom timing curve for smooth acceleration/deceleration
            withAnimation(.timingCurve(0.25, 0.1, 0.25, 1, duration: self.animationDuration)) {
                self.needleAngle = targetAngle
                self.progressAmount = segmentProgress
            }
        }
    }
    
    private func calculateNonLinearProgress(for value: Double) -> Double {
        let breakpoints = SpeedometerConfiguration.scaleBreakpoints
        
        for i in 0..<(breakpoints.count - 1) {
            let segmentStart = breakpoints[i]
            let segmentEnd = breakpoints[i + 1]
            
            if value >= segmentStart && value <= segmentEnd {
                // Calculate progress within this segment
                let segmentProgress = (value - segmentStart) / (segmentEnd - segmentStart)
                
                // Convert to overall progress
                let segmentSize = 1.0 / Double(breakpoints.count - 1)
                return (Double(i) * segmentSize) + (segmentProgress * segmentSize)
            }
        }
        
        return 1.0
    }

}


// MARK: - Animated Shapes

struct ProgressArcShape: Shape {
    var progressAmount: Double
    let radius: CGFloat
    let lineWidth: CGFloat
    
    var animatableData: Double {
        get { progressAmount }
        set { progressAmount = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startAngle = SpeedometerConfiguration.startAngle
        let endAngle = startAngle + (progressAmount * SpeedometerConfiguration.totalAngle)
        let startAngleRadians = startAngle * .pi / 180
        let endAngleRadians = endAngle * .pi / 180
        
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(radians: startAngleRadians),
            endAngle: Angle(radians: endAngleRadians),
            clockwise: false
        )
        return path
    }
}

struct NeedleShape: Shape {
    var angle: Double
    let length: CGFloat
    let width: CGFloat
    
    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let angleRadians = angle * .pi / 180
        
        let needleEnd = CGPoint(
            x: center.x + length * Darwin.cos(angleRadians),
            y: center.y + length * Darwin.sin(angleRadians)
        )
        
        var path = Path()
        path.move(to: center)
        path.addLine(to: needleEnd)
        return path
    }
    
   
}

#Preview {
    Speedometer(value: .constant(0), animationManager: SpeedometerAnimationManager())
        .frame(width: 308)
}


