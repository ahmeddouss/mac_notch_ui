# mac_notch_ui

A Flutter package to create a "Notch" style UI on macOS, similar to dynamic islands or notch tools.
It allows you to host Flutter content inside a notch that expands on hover.

## Features

- **Custom Notch Shape**: Matches the aesthetics of modern macOS notches.
- **Animation**: Smooth open/close animations on hover.
- **Service Mode**: Configuration to run as a background/status bar service (no Dock icon).
- **Flutter Content**: Add any Flutter widget inside the notch.

## Usage

1. **Add Dependency**:
   ```yaml
   dependencies:
     mac_notch_ui:
       path: .
   ```

2. **Configure Native Window**:
   Call `enableNotchMode()` in your `main()` or `initState()`.

   ```dart
   void main() {
     runApp(const MyApp());
   }
   
   // In your State
   await MacNotchUi().enableNotchMode();
   ```

3. **Use the Widget**:
   ```dart
   MacNotchWidget(
     child: Text("My Content"),
   )
   ```

4. **Service Mode Setup (Recommended)**:
   To make the app appear purely as a localized notch without a Dock icon or Main Window behavior:
   
   - Open `macos/Runner/Info.plist`.
   - Add the following key:
     ```xml
     <key>LSUIElement</key>
     <true/>
     ```
   - This hides the app from the Dock and Cmd+Tab switcher.

## Customization

You can customize the sizes and radius:

```dart
MacNotchWidget(
  closedSize: Size(150, 40),
  openSize: Size(500, 300),
  child: MyWidget(),
)
```
