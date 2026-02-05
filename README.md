# Mac Notch UI 

Bring the **Dynamic Island** experience to macOS with Flutter.

A powerful Flutter package that allows you to create a "Notch" style UI on macOS, blending seamlessly with the native aesthetics. Host any Flutter widget inside a dynamic, expanding notch that reacts to hover and user interactions.

<!-- Add a demo GIF here if available, otherwise keep this placeholder comment -->
<!-- <img src="https://your-demo-url.gif" width="100%" /> -->

## Key Highlights

- **Native Aesthetics**: Designed to perfectly match the modern macOS notch look and feel.
- **Smooth Animations**: Fluid, spring-based animations for opening and closing, just like native macOS interactions.
- **Service Mode**: Run your app as a background service or status bar tool without a Dock icon.
- **Flutter Powered**: Render *any* Flutter widget inside the notch—buttons, sliders, text, or complex UIs.
- **Hover Detection**: Automatically expands when the mouse hovers over the notch area (optional).
- **Fully Customizable**: Control sizes, border radius, blur intensity, and colors to fit your app's theme.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  mac_notch_ui: ^0.0.1
```

## Usage Examples

### 1. Initialize & Configure
Call `enableNotchMode()` in your `main()` or `initState()` to prepare the window.

```dart
void main() {
  runApp(const MyApp());
}

// Inside your StatefulWidget
@override
void initState() {
  super.initState();
  // Initialize the notch mode
  MacNotchUi().enableNotchMode();
}
```

### 2. Implement the Widget
Wrap your content in `MacNotchWidget`.

```dart
MacNotchWidget(
  closedSize: const Size(130, 30),
  openSize: const Size(400, 200),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Hello from the Notch!", style: TextStyle(color: Colors.white)),
      ElevatedButton(
        onPressed: () => print("Clicked!"), 
        child: const Text("Action")
      ),
    ],
  ),
)
```

### 3. Service Mode (Stealth)
To make your app feel like a true system extension (no Dock icon, no main window), update your `macos/Runner/Info.plist`:

```xml
<key>LSUIElement</key>
<true/>
```

## License

MIT License

---

## About the Author

Hi, I'm **Ahmed Douss**, a Flutter developer passionate about pushing the boundaries of what's possible on desktop and mobile. I built **Mac Notch UI** to give developers valid, native-feeling tools for creative macOS experiences. 

Feel free to connect on GitHub and share your feedback!

---

## ☕ Buy Me a Coffee

If you find this package helpful and want to support its development:

[![Buy Me a Coffee](https://img.shields.io/badge/Revolut-Buy%20me%20a%20coffee-blue?style=for-the-badge&logo=revolut)](https://revolut.me/adouss94)
