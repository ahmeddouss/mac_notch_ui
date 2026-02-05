import 'mac_notch_ui_platform_interface.dart';

export 'src/notch_widget.dart';
export 'src/notch_shape.dart';

class MacNotchUi {
  Future<String?> getPlatformVersion() {
    return MacNotchUiPlatform.instance.getPlatformVersion();
  }

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

  Future<void> setWindowSize(double width, double height, {double radius = 10.0}) {
    return MacNotchUiPlatform.instance.setWindowSize(width, height, radius: radius);
  }

  Future<void> animateWindowSize(double width, double height, {double radius = 10.0, double duration = 0.5}) {
    return MacNotchUiPlatform.instance.animateWindowSize(width, height, radius: radius, duration: duration);
  }

  Future<void> setBlurIntensity(double amount) {
    return MacNotchUiPlatform.instance.setBlurIntensity(amount);
  }

  Stream<bool> get onHoverZone {
    return MacNotchUiPlatform.instance.onHoverZone;
  }
}
