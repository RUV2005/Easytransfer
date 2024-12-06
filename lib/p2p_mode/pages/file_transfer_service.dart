import 'package:file_picker/file_picker.dart';
import 'package:flutter_p2p_connection/flutter_p2p_connection.dart';

class FileTransferService {
  final FlutterP2pConnection _flutterP2pConnectionPlugin = FlutterP2pConnection();

  Future<List<TransferUpdate>?> sendFileToSocket(String filePath) async {
    return await _flutterP2pConnectionPlugin.sendFiletoSocket([filePath]);
  }

  Future<PlatformFile?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    return result?.files.first;
  }
}