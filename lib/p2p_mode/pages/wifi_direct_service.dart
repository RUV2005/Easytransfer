import 'dart:async';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class WifiDirectService {
  final FlutterP2pConnection _flutterP2pConnectionPlugin = FlutterP2pConnection();
  List<DiscoveredPeers> peers = [];
  WifiP2PInfo? wifiP2PInfo;
  StreamSubscription<WifiP2PInfo>? _streamWifiInfo;
  StreamSubscription<List<DiscoveredPeers>>? _streamPeers;

  Future<void> initialize() async {
    await _flutterP2pConnectionPlugin.initialize();
    await _flutterP2pConnectionPlugin.register();

    _streamWifiInfo = _flutterP2pConnectionPlugin.streamWifiP2PInfo().listen((event) {
      wifiP2PInfo = event;
    });

    _streamPeers = _flutterP2pConnectionPlugin.streamPeers().listen((event) {
      peers = event;
    });
  }

  Future<void> startSocket(
      void Function(String, String) onConnect,
      void Function(TransferUpdate) transferUpdate,
      void Function(dynamic) receiveString,
      ) async {
    if (wifiP2PInfo != null) {
      await _flutterP2pConnectionPlugin.startSocket(
        groupOwnerAddress: wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 2,
        deleteOnError: true,
        onConnect: (dynamic address, dynamic info) {
          onConnect(address as String, info as String); // 强制转换
        },
        transferUpdate: transferUpdate,
        receiveString: receiveString,
      );
    }
  }

  Future<void> connectToSocket(
      void Function(String) onConnect,
      void Function(TransferUpdate) transferUpdate,
      void Function(dynamic) receiveString,
      ) async {
    if (wifiP2PInfo != null) {
      await _flutterP2pConnectionPlugin.connectToSocket(
        groupOwnerAddress: wifiP2PInfo!.groupOwnerAddress,
        downloadPath: "/storage/emulated/0/Download/",
        maxConcurrentDownloads: 3,
        deleteOnError: true,
        onConnect: (dynamic address) {
          onConnect(address as String); // 强制转换
        },
        transferUpdate: transferUpdate,
        receiveString: receiveString,
      );
    }
  }

  Future<void> closeSocketConnection() async {
    await _flutterP2pConnectionPlugin.closeSocket();
  }

  Future<bool?> createGroup() async {
    return await _flutterP2pConnectionPlugin.createGroup();
  }

  Future<bool?> removeGroup() async {
    return await _flutterP2pConnectionPlugin.removeGroup();
  }

  Future<String?> getIPAddress() async {
    return await _flutterP2pConnectionPlugin.getIPAddress();
  }

  Future<bool?> discover() async {
    return await _flutterP2pConnectionPlugin.discover();
  }

  Future<bool?> stopDiscovery() async {
    return await _flutterP2pConnectionPlugin.stopDiscovery();
  }

  List<DiscoveredPeers> getDiscoveredPeers() => peers;

  WifiP2PInfo? getWifiP2PInfo() => wifiP2PInfo;
}