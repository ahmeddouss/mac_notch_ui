import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mac_notch_ui/mac_notch_ui_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMacNotchUi platform = MethodChannelMacNotchUi();
  const MethodChannel channel = MethodChannel('mac_notch_ui');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
