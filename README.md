# 🚗 AnimatedSpeedometer

An interactive, animated speedometer built with SwiftUI featuring realistic racing-style animations and haptic feedback.

## ✨ Features

### 🎯 Core Functionality
- **Interactive Input**: Text field for entering speed values (0-100k+)
- **Smooth Animations**: Racing-style needle and progress arc animations
- **Realistic Feel**: Car startup sweep animation on first launch
- **Haptic Feedback**: Continuous haptic feedback during animations for immersive experience

### 🎨 Visual Design
- **Canvas-Based Rendering**: High-performance 60fps animations
- **Non-Linear Scale**: Realistic speedometer scale progression
- **Smart Formatting**: Intelligent number display (removes unnecessary decimals)
- **Responsive UI**: Maintains size when keyboard appears

### 🏗️ Architecture
- **Clean Code**: Follows Single Responsibility Principle and Separation of Concerns
- **Modular Design**: Dedicated managers for animations, formatting, and validation
- **SwiftUI Best Practices**: Uses `@State`, `@Binding`, and `animatableData` for smooth animations

## 🚀 Getting Started


### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/AhmadAzam/AnimatedSpeedometer.git
   ```
2. Open `AnimatedSpeedometer.xcodeproj` in Xcode
3. Build and run the project

## 🎮 Usage

1. **Launch the app** - Watch the startup sweep animation
2. **Enter a value** in the text field (supports numbers, decimals, and 'k' notation)
3. **Tap Submit** or press Enter to animate the speedometer
4. **Feel the haptics** during animation for a racing experience

### Input Examples
- `50` - Sets to 50
- `5.5k` - Sets to 5,500
- `120000` - Sets to 120k (needle caps at 100k, display shows actual value)

## 🛠️ Technical Details

### Architecture Overview
```
SpeedometerView (Main Container)
├── Speedometer (Visual Component)
│   ├── Canvas (Static Elements)
│   ├── ProgressArcShape (Animated Arc)
│   └── NeedleShape (Animated Needle)
├── SpeedometerAnimationManager (Animation Logic)
└── SpeedometerFormatter (Number Formatting)
```

### Key Components
- **`Speedometer.swift`**: Core visual component with Canvas-based rendering
- **`SpeedometerView.swift`**: Main container handling user interaction
- **`SpeedometerAnimationManager.swift`**: Manages animations and haptic feedback
- **`SpeedometerFormatter.swift`**: Handles intelligent number formatting

### Animation System
- Uses SwiftUI's `animatableData` protocol for smooth transitions
- Combines static Canvas elements with animated Shape components
- Racing-style easing curves for realistic motion
- Synchronized needle and progress arc animations

## 🎨 Customization

The speedometer can be customized through various parameters:
- Animation duration and easing curves
- Color schemes (defined in Assets.xcassets)
- Scale ranges and progressions
- Haptic feedback intensity

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- SwiftUI Canvas documentation and examples
- iOS haptic feedback best practices
---

**Made with ❤️ and SwiftUI**
