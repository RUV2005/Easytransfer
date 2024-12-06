import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

// 获取设备品牌
Future<String> getDeviceBrand() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String brand = "未知品牌";

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    brand = androidInfo.brand ?? '未知品牌';
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    brand = iosInfo.utsname.machine ?? '未知品牌';
  } else if (Platform.isWindows) {
    brand = 'PC';  // Windows 设备品牌设置为 PC
  }
  else if (Platform.isMacOS) {
    brand = 'PC';  // Macos 设备品牌设置为 PC
  }

  return brand;
}

// 获取Windows设备型号
Future<String> getDeviceModel() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String model = "未知型号";

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    model = androidInfo.model ?? '未知型号';
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    model = iosInfo.utsname.machine ?? '未知型号';
  } else if (Platform.isWindows) {
    model = 'Windows';  // Windows 设备型号设置为 Windows
  }
  else if (Platform.isMacOS) {
    model = 'Macos';  // Macos 设备型号设置为 Macos
  }
  else if (Platform.isIOS){
    model = "IOS";
  }

  return model;
}
