import 'package:flutter/material.dart';
import 'file_transfer_page.dart';

class TransferPage extends StatelessWidget {
  const TransferPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 示例设备列表
    final deviceList = [
      {'name': 'Device 1', 'ip': '192.168.1.1'},
      {'name': 'Device 2', 'ip': '192.168.1.2'},
      {'name': 'Device 3', 'ip': '192.168.1.3'},
      {'name': 'Device 4', 'ip': '192.168.1.4'},
    ];

    return ListView.builder(
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
    );
  }
}