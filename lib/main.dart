import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
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
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
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

class FileManager extends StatefulWidget {
  const FileManager({Key? key}) : super(key: key);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  late String _appFolderPath;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
      status = await Permission.storage.status;
    }
    if (status.isGranted) {
      _appFolderPath = '${Directory('/storage/emulated/0/Download').path}/Easytrasfer'; // 应用文件夹路径
      await _createAppFolder(); // 创建文件夹
      _listFiles(); // 列出文件
    } else {
      print('Storage permission denied');
    }
  }

  Future<void> _createAppFolder() async {
    final directory = Directory(_appFolderPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      print('App folder created at: $_appFolderPath');
    }
  }

  Future<void> _listFiles() async {
    final directory = Directory(_appFolderPath);
    if (await directory.exists()) {
      List<FileSystemEntity> entities = await directory.list().toList();
      setState(() {
        _files = entities.where((entity) {
          String name = entity.path.split('/').last;
          return !name.startsWith('.') && !name.isEmpty;
        }).toList()
          ..sort((a, b) => a.path.split('/').last.compareTo(b.path.split('/').last));
        _isLoading = false;
      });
    } else {
      print('Directory does not exist');
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final filePath = result.files.single.path!;
      final file = File(filePath);
      final newFile = await file.copy('$_appFolderPath/${file.uri.pathSegments.last}'); // 复制到应用专用文件夹
      setState(() {
        _files.add(newFile);
      });
    } else {
      print('No file selected');
    }
  }

  void _openDirectory(FileSystemEntity entity) {
    if (entity is Directory) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FileManagerPage(directory: entity),
        ),
      ).then((_) {
        _listFiles(); // 返回时重新列出文件
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('文件管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _pickFile,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return ListTile(
            title: Text(file.path.split('/').last),
            leading: Icon(file is Directory ? Icons.folder : Icons.insert_drive_file),
            onTap: () => _openDirectory(file),
          );
        },
      ),
    );
  }
}

class FileManagerPage extends StatelessWidget {
  final Directory directory;

  const FileManagerPage({Key? key, required this.directory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(directory.path.split('/').last)),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: directory.list().toList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final files = snapshot.data!
              .where((entity) => !entity.path.split('/').last.startsWith('.'))
              .toList()
            ..sort((a, b) => a.path.split('/').last.compareTo(b.path.split('/').last));

          return ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return ListTile(
                title: Text(file.path.split('/').last),
                leading: Icon(file is Directory ? Icons.folder : Icons.insert_drive_file),
                onTap: () {
                  if (file is Directory) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FileManagerPage(directory: file),
                      ),
                    );
                  } else {
                    print('Opening file: ${file.path}');
                  }
                },
              );
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
  bool _followSystemTheme = true;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _followSystemTheme = ThemeNotifier.instance.value;
  }

  void _resetSettings() {
    setState(() {
      _followSystemTheme = true;
      _notificationsEnabled = true;
      _selectedLanguage = 'English';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置', style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            SwitchListTile(
              title: const Text('跟随系统切换主题'),
              value: _followSystemTheme,
              onChanged: (bool value) {
                setState(() {
                  _followSystemTheme = value;
                  ThemeNotifier.instance.saveSettings(_followSystemTheme);
                });
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('启用通知'),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('选择语言'),
              subtitle: Text(_selectedLanguage),
              onTap: () {
                _showLanguageDialog();
              },
            ),
            const Divider(),
            TextButton(
              onPressed: _resetSettings,
              child: const Text('重置所有设置'),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择语言'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  title: const Text('English'),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'English';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('中文'),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = '中文';
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}