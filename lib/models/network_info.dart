import 'dart:io';
import 'dart:convert';
import 'package:network_info_plus/network_info_plus.dart';

Future<String?> getCurrentIP() async {
  final info = NetworkInfo();
  return await info.getWifiIP();
}

Future<String> getBroadcastAddress(String ip) async {
  List<String> parts = ip.split('.');
  return '${parts[0]}.${parts[1]}.${parts[2]}.255'; // 假设子网掩码是255.255.255.0
}

Future<void> sendBroadcast(String address, String message) async {
  RawDatagramSocket sender = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  sender.send(utf8.encode(message), InternetAddress(address), 22473);
  sender.close();
}