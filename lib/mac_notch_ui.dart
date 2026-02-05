import 'mac_notch_ui_platform_interface.dart';

export 'src/notch_widget.dart';
export 'src/notch_shape.dart';

/// The main class for controlling the macOS notch UI.
class MacNotchUi {
  /// Returns the platform version.
  Future<String?> getPlatformVersion() {
    return MacNotchUiPlatform.instance.getPlatformVersion();
  }

  /// Enables the notch mode with specified dimensions and effects.
  ///
  /// [width] The initial width of the notch.
  /// [height] The initial height of the notch.
  /// [blurIntensity] The intensity of the blur effect (0.0 to 1.0).
  Future<void> enableNotchMode({
    double width = 130, 
    double height = 30,
    double blurIntensity = 1.0,
  }) {
    return MacNotchUiPlatform.instance.enableNotchMode(
      width: width, 
      height: height,
      blurIntensity: blurIntensity,
    );
  }

  /// Sets the window size immediately.
  ///
  /// [width] The target width.
  /// [height] The target height.
  /// [radius] The corner radius.
  Future<void> setWindowSize(double width, double height, {double radius = 10.0}) {
    return MacNotchUiPlatform.instance.setWindowSize(width, height, radius: radius);
  }

  /// Animates the window size to the target dimensions.
  ///
  /// [width] The target width.
  /// [height] The target height.
  /// [radius] The target corner radius.
  /// [duration] The duration of the animation in seconds.
  Future<void> animateWindowSize(double width, double height, {double radius = 10.0, double duration = 0.5}) {
    return MacNotchUiPlatform.instance.animateWindowSize(width, height, radius: radius, duration: duration);
  }

  /// Sets the blur intensity of the notch background.
  ///
  /// [amount] The intensity value (0.0 to 1.0).
  Future<void> setBlurIntensity(double amount) {
    return MacNotchUiPlatform.instance.setBlurIntensity(amount);
  }

  /// Sets whether the notch window is visible in screenshare/screenshots.
  ///
  /// [visible] true to be visible, false to be hidden.
  Future<void> setScreenshareVisibility(bool visible) {
    return MacNotchUiPlatform.instance.setScreenshareVisibility(visible);
  }

  /// Stream that emits true when the mouse enters the hover zone, and false when it leaves.
  Stream<bool> get onHoverZone {
    return MacNotchUiPlatform.instance.onHoverZone;
  }
}
