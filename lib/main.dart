import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeNotifier.instance,
      builder: (context, followSystemTheme, child) {
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
          themeMode: followSystemTheme ? ThemeMode.system : ThemeMode.light,
          home: const MyHomePage(),
        );
      },
    );
  }
}

class ThemeNotifier extends ValueNotifier<bool> {
  static final ThemeNotifier instance = ThemeNotifier._().._loadSettings();

  ThemeNotifier._() : super(true);

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool('followSystemTheme') ?? true;
  }

  Future<void> saveSettings(bool value) async {
    this.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('followSystemTheme', value);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
    // 控制状态栏样式
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: isDarkMode ? Colors.black : Colors.white,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('')),  // 这里设置为空字符串
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent, // 设置为透明
        child: BottomNavigationBar(
          items: const [
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
              icon: Icon(Icons.share),
              label: '剪切板共享',
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
          onTap: _onItemTapped,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          elevation: 0, // 去除阴影
          backgroundColor: Colors.transparent, // 设置为透明
        ),
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
              // 在此处添加点击文件的逻辑
            },
          );
        },
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _followSystemTheme = true; // 默认跟随系统主题

  @override
  void initState() {
    super.initState();
    _followSystemTheme = ThemeNotifier.instance.value; // 获取当前状态
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('剪切板共享'),
            value: false, // 这里可以根据实际需求调整
            onChanged: (bool value) {
              // 在此处添加逻辑以更改剪切板共享功能
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('跟随系统切换主题'),
            value: _followSystemTheme,
            onChanged: (bool value) {
              setState(() {
                _followSystemTheme = value;
                ThemeNotifier.instance.saveSettings(_followSystemTheme); // 保存设置
              });
            },
          ),
          const Divider(),
          // 其他设置项...
        ],
      ),
    );
  }
}