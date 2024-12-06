import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/network_info.dart'; // 导入网络信息类
import '../../models/device_info.dart'; // 导入设备信息类

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
    scanNetwork();
  }

  Future<void> startListening() async {
    receiver = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 22473);
    receiver.listen((RawSocketEvent event) async {
      if (event == RawSocketEvent.read) {
        Datagram? datagram = receiver.receive();
        if (datagram != null) {
          _handleReceivedData(datagram);
        }
      }
    });
  }

  Future<void> _handleReceivedData(Datagram datagram) async {
    // 处理接收到的数据报逻辑
  }

  Future<void> scanNetwork() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    if (kIsWeb) return;

    String? wifiIP = await getCurrentIP();
    if (wifiIP == null) {
      setState(() {
        isScanning = false;
      });
      return;
    }

    String broadcastAddress = await getBroadcastAddress(wifiIP);
    Timer.periodic(Duration(seconds: 1), (timer) async {
      // 构建要发送的消息
      String message = 'Hello from Flutter;Brand:${await getDeviceBrand()};Model:${await getDeviceModel()}';
      await sendBroadcast(broadcastAddress, message);
    });
    scanTimer = Timer(Duration(seconds: 5), stopScanning);
  }

  Future<void> stopScanning() async {
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
        title: const Text('文件发送'),
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
          return GestureDetector(
            onTap: () {
              // 跳转到文件选择页面
            },
            child: Card(
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
            ),
          );
        },
      ),
    );
  }
}