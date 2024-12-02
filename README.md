# easytransfer

A new transfer project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

在 Flutter 中实现 Wi-Fi Direct 功能，可以通过调用原生代码来实现。以下是一个基本的实现步骤：

创建 Flutter 插件
首先，你需要创建一个 Flutter 插件，用于封装原生代码。可以使用 flutter create --template=plugin wifi_direct_plugin 命令创建插件项目。
编写 Android 原生代码
在 android/src/main/java/com/example/wifi_direct_plugin 目录下，创建一个 Java 类来处理 Wi-Fi Direct 的逻辑。例如：
```java
package com.example.wifi_direct_plugin;

import android.net.wifi.p2p.WifiP2pManager;
import android.net.wifi.p2p.WifiP2pManager.Channel;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class WifiDirectPlugin implements FlutterPlugin, MethodCallHandler {
    private WifiP2pManager manager;
    private Channel channel;
    private MethodChannel channel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "wifi_direct_plugin");
        channel.setMethodCallHandler(this);
        manager = (WifiP2pManager) flutterPluginBinding.getApplicationContext().getSystemService(Context.WIFI_P2P_SERVICE);
        channel = manager.initialize(flutterPluginBinding.getApplicationContext(), flutterPluginBinding.getApplicationContext().getMainLooper(), null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("discoverPeers")) {
            manager.discoverPeers(channel, new WifiP2pManager.ActionListener() {
                @Override
                public void onSuccess() {
                    result.success("Discovery started");
                }

                @Override
                public void onFailure(int reason) {
                    result.error("DISCOVERY_FAILED", "Discovery failed", reason);
                }
            });
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
```

在 Flutter 项目中使用插件
在 Flutter 项目中，添加插件依赖并调用方法。例如：
```dart
import 'package:flutter/material.dart';
import 'package:wifi_direct_plugin/wifi_direct_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Wi-Fi Direct Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              WifiDirectPlugin.discoverPeers().then((value) {
                print(value);
              }).catchError((error) {
                print(error);
              });
            },
            child: Text('Discover Peers'),
          ),
        ),
      ),
    );
  }
}
```
请注意，由于 iOS 平台不支持 Wi-Fi Direct，你可能需要使用其他方法或第三方库来实现类似的功能。上述代码仅在 Android 平台上有效。