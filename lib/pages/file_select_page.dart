import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TransferFilesPage extends StatefulWidget {
  final String deviceName;
  final String deviceIp;

  const TransferFilesPage({Key? key, required this.deviceName, required this.deviceIp}) : super(key: key);

  @override
  _TransferFilesPageState createState() => _TransferFilesPageState();
}

class _TransferFilesPageState extends State<TransferFilesPage> {
  PlatformFile? pickedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transfer Files to ${widget.deviceName}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _pickFile, child: const Text('Add File')),
            if (pickedFile != null) Text('Selected file: ${pickedFile!.name}'),
          ],
        ),
      ),
    );
  }
}