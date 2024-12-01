import 'package:flutter/material.dart';
import 'transfer_page.dart';
import 'file_transfer_page.dart'; // 确保导入
import 'file_manager_page.dart';
import 'settings_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    TransferPage(),
    TransferFilesPage(deviceName: 'Device', deviceIp: '192.168.1.1'), // 使用正确的类名
    Center(child: Text('接收文件', style: TextStyle(fontSize: 24))),
    Center(child: Text('剪切板共享', style: TextStyle(fontSize: 24))),
    FileManager(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '主页'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: '文件传输'),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: '接收文件'),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: '剪切板共享'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: '文件管理'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}