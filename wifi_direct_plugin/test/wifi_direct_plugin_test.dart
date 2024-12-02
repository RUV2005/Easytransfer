import 'package:flutter_test/flutter_test.dart';
import 'package:wifi_direct_plugin/wifi_direct_plugin.dart';
import 'package:wifi_direct_plugin/wifi_direct_plugin_platform_interface.dart';
import 'package:wifi_direct_plugin/wifi_direct_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWifiDirectPluginPlatform
    with MockPlatformInterfaceMixin
    implements WifiDirectPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WifiDirectPluginPlatform initialPlatform = WifiDirectPluginPlatform.instance;

  test('$MethodChannelWifiDirectPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWifiDirectPlugin>());
  });

  test('getPlatformVersion', () async {
    WifiDirectPlugin wifiDirectPlugin = WifiDirectPlugin();
    MockWifiDirectPluginPlatform fakePlatform = MockWifiDirectPluginPlatform();
    WifiDirectPluginPlatform.instance = fakePlatform;

    expect(await wifiDirectPlugin.getPlatformVersion(), '42');
  });
}
