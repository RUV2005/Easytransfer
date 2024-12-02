import 'package:flutter/material.dart';

import '../widgets/theme_notifier.dart';
import '../widgets/wifi_direct_plugin.dart';

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
    _followSystemTheme = ThemeNotifier.instance.value; // 获取当前主题设置
  }

  void _debug(){
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const WifiDirectPage()));
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
      appBar: AppBar(title: const Text('设置')),
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
            _buildSettingItem(
              TextButton(
                onPressed: _debug,
                child: const Text('调试页面'),
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