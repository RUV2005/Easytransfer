import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wifi_direct_plugin_method_channel.dart';

abstract class WifiDirectPluginPlatform extends PlatformInterface {
  /// Constructs a WifiDirectPluginPlatform.
  WifiDirectPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiDirectPluginPlatform _instance = MethodChannelWifiDirectPlugin();

  /// The default instance of [WifiDirectPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelWifiDirectPlugin].
  static WifiDirectPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiDirectPluginPlatform] when
  /// they register themselves.
  static set instance(WifiDirectPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
