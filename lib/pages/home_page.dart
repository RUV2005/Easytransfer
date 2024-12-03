import 'package:flutter/material.dart';
import 'file_transfer_page.dart';
import 'file_select_page.dart'; // 确保导入
import 'settings_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(); // 添加 PageController

  final List<Widget> _pages = const [
    TransferPage(),
    TransferFilesPage(deviceName: 'Device', deviceIp: '192.168.1.1'), // 使用正确的类名
    SettingsPage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index); // 使用 PageController 跳转到指定页面
  }

  @override
  void dispose() {
    _pageController.dispose(); // 释放资源
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController, // 设置 PageController
        onPageChanged: _onPageChanged, // 监听页面变化
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '主页'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: '文件传输'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '设置'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // 点击导航栏时调用
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}