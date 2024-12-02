import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wifi_direct_plugin_platform_interface.dart';

/// An implementation of [WifiDirectPluginPlatform] that uses method channels.
class MethodChannelWifiDirectPlugin extends WifiDirectPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wifi_direct_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
