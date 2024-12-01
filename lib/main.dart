import 'package:easytransfer/transfer_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'language_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentLocale = 'zh'; // 默认语言

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
          locale: Locale(_currentLocale), // 使用当前语言
          home: const MyHomePage(),
        );
      },
    );
  }

  void updateLocale(String locale) {
    setState(() {
      _currentLocale = locale;
    });
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
    TransferPage(),
    FileTransferPage(),
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


class FileTransferPage extends StatelessWidget {
  const FileTransferPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 增加整体间距
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // 使按钮宽度填满
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // 媒体按钮的逻辑
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.media,
                    );
                    _handleFileSelection(result);
                  },
                  child: const Text('媒体'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 文件按钮的逻辑
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                    );
                    _handleFileSelection(result);
                  },
                  child: const Text('文件'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 文件夹按钮的逻辑
                    _selectDirectory(context);
                  },
                  child: const Text('文件夹'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 应用按钮的逻辑
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['apk'], // 允许选择应用文件
                    );
                    _handleFileSelection(result);
                  },
                  child: const Text('应用'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleFileSelection(FilePickerResult? result) {
    if (result != null && result.files.isNotEmpty) {
      // 处理选择的文件
      final file = result.files.first;
      print('选中的文件: ${file.name}');
    } else {
      print('未选择任何文件');
    }
  }

  void _selectDirectory(BuildContext context) async {
    print('请手动选择文件夹');

    // 在这里使用pickFiles进行选择
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );

    if (result != null && result.paths.isNotEmpty) {
      final path = result.paths.first;
      print('选中的文件夹: $path');
      // 这里可以添加进一步的处理逻辑
    } else {
      print('未选择任何文件夹');
    }
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
      _appFolderPath = '${Directory('/storage/emulated/0/Download').path}/Easytransfer'; // 应用文件夹路径
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
  String _selectedLanguage = '简体中文';
  String _selectedTransferMode = 'WLAN 直连';
  final List<String> _transferModes = ['WLAN 直连', 'WiFi 模式', '热点模式'];

  @override
  void initState() {
    super.initState();
    _followSystemTheme = ThemeNotifier.instance.value;
  }

  void _resetSettings() {
    setState(() {
      _followSystemTheme = true;
      _notificationsEnabled = true;
      _selectedLanguage = '简体中文';
      _selectedTransferMode = 'WLAN 直连';
    });
  }

  Widget _buildSettingItem(Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置', style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            _buildSettingItem(
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
            ),
            _buildSettingItem(
              SwitchListTile(
                title: const Text('启用通知'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ),
            _buildSettingItem(
              ListTile(
                title: const Text('选择语言'),
                subtitle: Text(_selectedLanguage),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
            ),
            _buildSettingItem(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('文件传输模式'),
                    DropdownButton<String>(
                      value: _selectedTransferMode,
                      items: _transferModes.map((String mode) {
                        return DropdownMenuItem<String>(
                          value: mode,
                          child: Text(mode),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTransferMode = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            _buildSettingItem(
              TextButton(
                onPressed: _resetSettings,
                child: const Text('重置所有设置'),
              ),
            ),
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
                  title: const Text('简体中文'),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = '简体中文';
                    });
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('English'),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = 'English';
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