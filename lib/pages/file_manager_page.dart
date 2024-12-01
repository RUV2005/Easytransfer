import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class FileManager extends StatefulWidget {
  const FileManager({Key? key}) : super(key: key);

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestStoragePermission();
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if (status.isGranted) {
      _listFiles();
    }
  }

  Future<void> _listFiles() async {
    final directory = Directory('/storage/emulated/0/Download');
    if (await directory.exists()) {
      List<FileSystemEntity> entities = await directory.list().toList();
      setState(() {
        _files = entities.where((entity) => !entity.path.split('/').last.startsWith('.')).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件管理')),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : ListView.builder(
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return ListTile(
            title: Text(file.path.split('/').last),
            leading: Icon(file is Directory ? Icons.folder : Icons.insert_drive_file),
            onTap: () {
              // 处理文件夹或文件的点击事件
            },
          );
        },
      ),
    );
  }
}