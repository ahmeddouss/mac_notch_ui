import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mac_notch_ui_platform_interface.dart';



/// An implementation of [MacNotchUiPlatform] that uses method channels.
class MethodChannelMacNotchUi extends MacNotchUiPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mac_notch_ui');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> enableNotchMode({
    double width = 130, 
    double height = 30,
    double blurIntensity = 1.0,
  }) async {
    await methodChannel.invokeMethod<void>('enableNotchMode', {
      'width': width,
      'height': height,
      'blurIntensity': blurIntensity,
    });
  }

  @override
  Future<void> setWindowSize(double width, double height, {double radius = 10}) async {
    await methodChannel.invokeMethod<void>('setWindowSize', {
      'width': width,
      'height': height,
      'radius': radius,
    });
  }

  @override
  Future<void> animateWindowSize(double width, double height, {double radius = 10, double duration = 0.5}) async {
    await methodChannel.invokeMethod<void>('animateWindow', {
      'width': width,
      'height': height,
      'radius': radius,
      'duration': duration,
    });
  }

  @override
  Future<void> setBlurIntensity(double amount) async {
    await methodChannel.invokeMethod<void>('setBlurIntensity', amount);
  }

  // Bridging the method channel events to a stream
  final _hoverController = StreamController<bool>.broadcast();

  @override
  Stream<bool> get onHoverZone {
    if (_hoverController.hasListener) return _hoverController.stream;
    
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == 'onHoverZone') {
        final inZone = call.arguments as bool;
        _hoverController.add(inZone);
      }
    });
    return _hoverController.stream;
  }
}
