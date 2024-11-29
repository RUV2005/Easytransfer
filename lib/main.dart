import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // 页面列表
  final List<Widget> _pages = const [
    Center(child: Text('主页', style: TextStyle(fontSize: 24))),
    Center(child: Text('文件传输', style: TextStyle(fontSize: 24))),
    Center(child: Text('接收文件', style: TextStyle(fontSize: 24))),
    FileManager(),
    Center(child: Text('设置', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? Colors.black : Colors.white,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    final bottomNavBarColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final selectedItemColor = isDarkMode ? Colors.lightBlueAccent : Colors.deepPurple;
    final unselectedItemColor = isDarkMode ? Colors.white54 : Colors.grey;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '主页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: '文件传输',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: '接收文件',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: '文件管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        backgroundColor: bottomNavBarColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

class FileManager extends StatefulWidget {
  const FileManager({Key? key}) : super(key: key);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  Future<void> _listFiles() async {
    final Directory directory = Directory('/sdcard');
    setState(() {
      _files = directory.listSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件管理'),
      ),
      body: ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return ListTile(
            title: Text(file.path.split('/').last),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}