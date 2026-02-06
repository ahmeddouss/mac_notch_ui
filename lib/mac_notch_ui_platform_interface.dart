import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mac_notch_ui_method_channel.dart';

abstract class MacNotchUiPlatform extends PlatformInterface {
  /// Constructs a MacNotchUiPlatform.
  MacNotchUiPlatform() : super(token: _token);

  static final Object _token = Object();

  static MacNotchUiPlatform _instance = MethodChannelMacNotchUi();

  /// The default instance of [MacNotchUiPlatform] to use.
  ///
  /// Defaults to [MethodChannelMacNotchUi].
  static MacNotchUiPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MacNotchUiPlatform] when
  /// they register themselves.
  static set instance(MacNotchUiPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Enables the notch mode with specified parameters.
  ///
  /// * [width]: The initial width.
  /// * [height]: The initial height.
  /// * [blurIntensity]: The blur intensity (0.0 to 1.0).
  Future<void> enableNotchMode({
    double width = 130, 
    double height = 30, 
    double blurIntensity = 1.0,
  }) {
    throw UnimplementedError('enableNotchMode() has not been implemented.');
  }

  /// Sets the window size.
  ///
  /// * [width]: The target width.
  /// * [height]: The target height.
  /// * [radius]: The target radius.
  Future<void> setWindowSize(double width, double height, {double radius = 10}) {
    throw UnimplementedError('setWindowSize() has not been implemented.');
  }

  /// Animates the window size.
  ///
  /// * [width]: The target width.
  /// * [height]: The target height.
  /// * [radius]: The target radius.
  /// * [duration]: Animation duration in seconds.
  Future<void> animateWindowSize(double width, double height, {double radius = 10, double duration = 0.5}) {
    throw UnimplementedError('animateWindowSize() has not been implemented.');
  }

  /// Sets the blur intensity.
  ///
  /// * [amount]: The intensity value (0.0 to 1.0).
  Future<void> setBlurIntensity(double amount) {
    throw UnimplementedError('setBlurIntensity() has not been implemented.');
  }

  /// Sets visibility in screenshares.
  ///
  /// * [visible]: Whether the window should be visible in captures.
  Future<void> setScreenshareVisibility(bool visible) {
    throw UnimplementedError('setScreenshareVisibility() has not been implemented.');
  }

  /// Stream of hover zone events.
  ///
  /// Emits `true` when entering the zone, `false` when leaving.
  Stream<bool> get onHoverZone {
    throw UnimplementedError('onHoverZone has not been implemented.');
  }
}
