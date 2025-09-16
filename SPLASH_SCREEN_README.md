# AyurSeva Splash Screen Implementation

## Overview
This document describes the splash screen implementation for the AyurSeva Flutter application.

## Features
- **Background Image**: Uses `assets/images/splash_bg.png` as a full-screen background
- **Animated Logo**: Displays `assets/icons/logo.svg` with fade-in and scale animations
- **Smooth Transitions**: 3-second display duration with automatic navigation to home screen
- **Responsive Design**: Works across all device sizes and orientations

## Implementation Details

### Files Created/Modified
1. **`lib/splash_screen/splash_screen.dart`** - Main splash screen widget
2. **`lib/main.dart`** - Updated to include splash screen routing
3. **`pubspec.yaml`** - Added required dependencies and asset paths

### Dependencies Added
- `flutter_svg: ^2.0.10+1` - For rendering SVG logo
- `http: ^1.1.0` - For network utilities (existing utils)

### Animation Details
- **Fade Animation**: Logo fades in over 0-60% of animation duration
- **Scale Animation**: Logo scales from 0.8x to 1.0x with elastic bounce effect
- **Total Duration**: 2 seconds for animations, 3 seconds total display time

### Asset Requirements
- `assets/images/splash_bg.png` - Background image (blurred wellness environment)
- `assets/icons/logo.svg` - Circular logo with medical/healing theme

### Navigation Flow
1. App starts → Splash Screen (3 seconds)
2. Automatic navigation → Home Page
3. Route: `/` → `/home`

## Usage
The splash screen is automatically displayed when the app launches. No additional configuration is required.

## Customization
To modify the splash screen:
- Change animation duration in `_animationController`
- Adjust logo size by modifying the Container dimensions
- Update background image by replacing `splash_bg.png`
- Modify navigation timing in `_navigateToMainApp()`

## Logging
The implementation includes comprehensive logging for debugging:
- Splash screen initialization
- Animation state changes
- Navigation events
- Widget lifecycle events
