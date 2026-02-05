import 'package:flutter_test/flutter_test.dart';
import 'package:mac_notch_ui/mac_notch_ui.dart';
import 'package:mac_notch_ui/mac_notch_ui_platform_interface.dart';
import 'package:mac_notch_ui/mac_notch_ui_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMacNotchUiPlatform
    with MockPlatformInterfaceMixin
    implements MacNotchUiPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MacNotchUiPlatform initialPlatform = MacNotchUiPlatform.instance;

  test('$MethodChannelMacNotchUi is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMacNotchUi>());
  });

  test('getPlatformVersion', () async {
    MacNotchUi macNotchUiPlugin = MacNotchUi();
    MockMacNotchUiPlatform fakePlatform = MockMacNotchUiPlatform();
    MacNotchUiPlatform.instance = fakePlatform;

    expect(await macNotchUiPlugin.getPlatformVersion(), '42');
  });
}
