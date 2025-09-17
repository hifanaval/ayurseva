# AyurSeva Logout Functionality Implementation

## Overview
This document describes the logout functionality implementation for the AyurSeva Flutter application, including token management and navigation flow.

## Features Implemented

### 1. Logout Function in AuthProvider
- **Token Clearing**: Removes token from SharedPreferences and global variable
- **Form Reset**: Clears all form fields and resets state
- **Navigation**: Automatically navigates to login screen after logout
- **Error Handling**: Proper try-catch blocks with logging

### 2. Logout Button in Home Screen
- **UI Design**: Styled logout button with icon and text
- **Positioning**: Replaced back button with logout button in header
- **Integration**: Uses AuthProvider for logout functionality

### 3. Token-Based Navigation in Splash Screen
- **Token Check**: Verifies if user has valid token on app startup
- **Smart Navigation**: 
  - If token exists → Navigate to Home Screen
  - If no token → Navigate to Login Screen
- **Error Handling**: Defaults to login screen on any errors

## Implementation Details

### AuthProvider Enhancements

#### New Methods Added:
```dart
// Check if user has valid token
Future<bool> hasValidToken() async

// Logout function with complete cleanup
Future<void> logout(BuildContext context) async

// Get stored token
Future<String> getStoredToken() async
```

#### Logout Process:
1. Clear token from SharedPreferences
2. Clear global authToken variable
3. Reset form fields and state
4. Clear login response model
5. Navigate to login screen with route clearing

### Home Screen Updates

#### Logout Button Features:
- **Visual Design**: Green button with logout icon and text
- **Positioning**: Left side of header (replaced back button)
- **Functionality**: Calls AuthProvider logout method
- **User Experience**: Immediate logout with navigation

### Splash Screen Navigation Logic

#### Smart Navigation Flow:
```dart
void _navigateToNextScreen() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final hasToken = await authProvider.hasValidToken();
  
  if (hasToken) {
    // Navigate to home screen
    AppUtils.navigateTo(context, const TreatmentsListScreen());
  } else {
    // Navigate to login screen
    AppUtils.navigateTo(context, const LoginScreen());
  }
}
```

## User Flow

### First Time User:
1. App starts → Splash Screen
2. No token found → Login Screen
3. User logs in → Token saved → Home Screen
4. User can logout → Token cleared → Login Screen

### Returning User:
1. App starts → Splash Screen
2. Valid token found → Home Screen (skip login)
3. User can logout → Token cleared → Login Screen

### Logout Process:
1. User taps logout button
2. Token cleared from storage
3. Form reset
4. Navigation to login screen
5. All previous routes cleared

## Security Features

### Token Management:
- **Secure Storage**: Uses SharedPreferences for token persistence
- **Global Access**: Token available throughout app via global variable
- **Complete Cleanup**: All traces of user session removed on logout

### Navigation Security:
- **Route Clearing**: `pushAndRemoveUntil` prevents back navigation
- **State Reset**: All authentication state cleared
- **Error Handling**: Graceful fallback to login screen

## Dependencies Used
- **shared_preferences**: Token persistence
- **provider**: State management
- **dio**: API communication (existing)

## Files Modified

### 1. `lib/login_screen/provider/auth_provider.dart`
- Added logout functionality
- Added token checking methods
- Enhanced error handling

### 2. `lib/home_screen/home_screen.dart`
- Added logout button
- Imported AuthProvider
- Updated header layout

### 3. `lib/splash_screen/splash_screen.dart`
- Added token-based navigation
- Imported necessary dependencies
- Enhanced navigation logic

## Testing Scenarios

### Test Cases:
1. **Fresh Install**: App should navigate to login screen
2. **Valid Token**: App should navigate to home screen
3. **Logout**: Should clear token and navigate to login
4. **Token Expiry**: Should handle invalid tokens gracefully
5. **Network Issues**: Should handle API errors properly

### Expected Behavior:
- Smooth navigation between screens
- Proper token persistence
- Complete logout functionality
- Error handling and recovery

## Future Enhancements

### Potential Improvements:
- **Token Refresh**: Automatic token renewal
- **Biometric Logout**: Fingerprint/face recognition
- **Session Timeout**: Automatic logout after inactivity
- **Multi-Device Logout**: Logout from all devices
- **Logout Confirmation**: Dialog before logout
- **Analytics**: Track logout events

## Security Considerations

### Best Practices Implemented:
- Complete token cleanup on logout
- Route clearing to prevent back navigation
- Error handling for edge cases
- Proper state management
- Secure storage practices

### Recommendations:
- Implement token expiration checking
- Add session timeout functionality
- Consider implementing refresh tokens
- Add logout confirmation dialog
- Implement proper error logging
