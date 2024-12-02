import 'dart:async';
import 'dart:convert';
import 'dart:io'; // 仅在非 Web 平台使用
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  List<Map<String, String>> devices = [];
  bool isScanning = false;
  late RawDatagramSocket receiver;
  Timer? scanTimer;

  @override
  void initState() {
    super.initState();
    startListening();
    scanNetwork(); // 启动时自动扫描
  }

  Future<void> startListening() async {
    receiver = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 22473);
    receiver.listen((RawSocketEvent event) async {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = receiver.receive();
        if (datagram != null) {
          print('Received raw data: ${datagram.data}'); // 打印原始数据
          try {
            final message = utf8.decode(datagram.data, allowMalformed: true);
            final ip = datagram.address.address;

            if (ip != await _getCurrentIP()) {
              final parts = message.split(';');
              String deviceBrand = parts.length > 1 ? parts[1].replaceFirst('Brand:', '') : '未知品牌';
              String deviceModel = parts.length > 2 ? parts[2].replaceFirst('Model:', '') : '未知型号';

              // 进行去重检查
              if (!devices.any((device) => device['ip'] == ip)) {
                setState(() {
                  devices.add({
                    'ip': ip,
                    'port': '22473',
                    'status': '响应',
                    'brand': deviceBrand,
                    'model': deviceModel
                  });
                });
              }
            }
          } catch (e) {
            print('Failed to decode data: $e'); // 处理解码失败
            return; // 跳过此无效数据
          }
        }
      }
    });
  }

  Future<void> scanNetwork() async {
    setState(() {
      isScanning = true;
      devices.clear(); // 清空设备列表以便重新扫描
    });

    if (kIsWeb) {
      // Web 平台的逻辑（如果需要的话）
      return; // 目前不支持 Windows 的广播发送
    } else {
      // 在非 Web 平台（如 Windows）获取当前 IP
      String? wifiIP = await _getCurrentIP();
      if (wifiIP == null) {
        setState(() {
          isScanning = false;
        });
        return;
      }

      String broadcastAddress = await getBroadcastAddress(wifiIP);

      // 启动持续的广播发送
      Timer.periodic(Duration(milliseconds: 100), (timer) async {
        await sendBroadcast(broadcastAddress); // 使用动态计算的广播地址
      });

      // 设置扫描超时
      scanTimer = Timer(Duration(seconds: 5), () {
        stopScanning();
      });
    }
  }

  Future<void> sendBroadcast(String address) async {
    String message;

    // 仅在非 Web 平台使用 Platform 属性
    if (Platform.isWindows) {
      message = 'Hello from Windows;Brand:Windows;Model:PC';
    } else {
      String deviceBrand = await _getDeviceBrand();
      String deviceModel = await _getDeviceModel();
      message = 'Hello from Flutter;Brand:$deviceBrand;Model:$deviceModel';
    }

    RawDatagramSocket sender = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    sender.send(utf8.encode(message), InternetAddress(address), 22473); // 发送到指定地址
    sender.close();
  }

  Future<String?> _getCurrentIP() async {
    final info = NetworkInfo();
    return await info.getWifiIP();
  }

  Future<String> _getDeviceBrand() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String brand = "未知品牌";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      brand = androidInfo.brand!;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      brand = iosInfo.utsname.machine!;
    }

    return brand;
  }

  Future<String> _getDeviceModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String model = "未知型号";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = androidInfo.model!;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.utsname.machine!;
    }

    return model;
  }

  Future<String> getBroadcastAddress(String ip) async {
    List<String> parts = ip.split('.');
    return '${parts[0]}.${parts[1]}.${parts[2]}.255'; // 假设使用的子网掩码是 255.255.255.0
  }

  void stopScanning() {
    setState(() {
      isScanning = false;
    });
    scanTimer?.cancel();
  }

  @override
  void dispose() {
    receiver.close();
    scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备发现'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              scanNetwork();
            },
          ),
        ],
      ),
      body: isScanning
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(devices[index]['ip'] ?? '未知 IP'),
                      Text('端口: 22473'),
                      Text('状态: ${devices[index]['status'] ?? '未知'}'),
                      Text('品牌: ${devices[index]['brand'] ?? '未知品牌'}'),
                      Text('型号: ${devices[index]['model'] ?? '未知型号'}'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}