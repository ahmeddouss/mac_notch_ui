# macOS Notch UI

A Flutter package that brings the native macOS notch experience to your Flutter desktop apps. Create interactive, animated, and customizable notch-style windows that hover at the top of the screen.

Designed with a focus on **native performance** and **Flutter flexibility**.

![notch_3 (1) (1)](https://github.com/user-attachments/assets/fafd6ddc-0547-4527-9251-0e483aa6f1ba)

## ✨ Features

- **Native macOS Integration**: Uses native `NSWindow` for a seamless "always-on-top" experience.
- **Smooth Animations**: Native-driven animations for opening, closing, and resizing with a delightful bounce effect.
- **Flutter Content**: Render *any* Flutter widget inside the notch.
- **Hover Detection**: Automatically expands or reacts when the mouse hovers over the notch area.
- **Dynamic Resizing**: distinct open and closed sizes with smooth interpolation.
- **Customizable Appearance**:
  - Adjust width, height, and corner radius.
  - Configurable blur intensity (Glassmorphism).
  - Custom background colors and opacity.
- **Screenshare Privacy**: Option to automatically hide the notch during screen sharing or screenshots.
- **Multi-Monitor Support**: (Experimental) Works across different screens.

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  mac_notch_ui: ^1.0.0
```

## 🚀 Usage

The easiest way to use this package is with the `MacNotchWidget`, which handles all the animations and state management for you.

### 1. Initialize the Plugin
In your `main()` or base widget, enable the notch mode.

```dart
final _macNotchUiPlugin = MacNotchUi();

@override
void initState() {
  super.initState();
  // Initialize transparent window and notch mode
  _macNotchUiPlugin.enableNotchMode(blurIntensity: 1.0);
}
```

### 2. Use the Widget
Wrap your content in `MacNotchWidget`.

```dart
MacNotchWidget(
  isOpen: _isExpanded, // Control state
  onExpansionChanged: (isOpen) => setState(() => _isExpanded = isOpen),
  
  // Customization
  closedSize: const Size(130, 30),
  openSize: const Size(500, 300),
  openRadius: 24,
  blurIntensity: 0.8,
  
  builder: (closeNotch) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text("My Notch App"),
          ElevatedButton(
            onPressed: closeNotch, 
            child: Text("Close")
          ),
        ],
      ),
    );
  },
)
```

## ⚙️ Advanced Configuration

### Controller API
You can control the native window directly using the `MacNotchUi` class:

```dart
// Resize the window directly
await MacNotchUi().animateWindowSize(500, 400, radius: 20, duration: 0.5);

// Update background blur
await MacNotchUi().setBlurIntensity(0.5);

// Hide from screenshares
await MacNotchUi().setScreenshareVisibility(false);
```

### Hover Detection
Listen to the hover stream to build passive interactions:

```dart
MacNotchUi().onHoverZone.listen((isHovered) {
  if (isHovered) {
    print("Mouse is over the notch!");
    // Trigger expansion or show a preview
  }
});
```

## 🔧 Platform Support

| Platform | Supported |
|----------|-----------|
| macOS    | ✅        |
| Windows  | ❌        |
| Linux    | ❌        |
| Mobile   | ❌        |

*Note: This package relies on macOS-specific windowing APIs (`NSWindow`, `NSVisualEffectView`).*

## ❤️ Contributing

Contributions are welcome! If you find a bug or want to feature, please open an issue.

## ✍️ Author

Created with passion by **Ahmed Douss**.
