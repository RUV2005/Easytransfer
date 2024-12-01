import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<StatefulWidget> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  List<Map<String, String>> deviceList = [
    {'name': 'Device 1', 'ip': '192.168.1.1'},
    {'name': 'Device 2', 'ip': '192.168.1.2'},
    {'name': 'Device 3', 'ip': '192.168.1.3'},
    {'name': 'Device 4', 'ip': '192.168.1.4'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: deviceList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransferFilesPage(
                    deviceName: deviceList[index]['name'] ?? 'Unknown Device',
                    deviceIp: deviceList[index]['ip'] ?? 'Unknown IP',
                  ),
                ),
              );
              print(index);
            },
            child: Card(
              margin: const EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deviceList[index]['name'] ?? 'Unknown Device'),
                        Text(deviceList[index]['ip'] ?? 'Unknown IP'),
                      ],
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TransferFilesPage extends StatefulWidget {
  final String deviceName;
  final String deviceIp;

  const TransferFilesPage(
      {super.key, required this.deviceName, required this.deviceIp});

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
    } else {
      // 用户取消了文件选择
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transfer Files to ${widget.deviceName}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _pickFile,
                child: Text('Add File'),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Send the file to the device
                },
                child: Text('Send File'),
              ),
            ),

            if (pickedFile != null) Text('Selected file: ${pickedFile!.name}'),
          ],
        ),
      ),
    );
  }
}
