import 'package:file_access/file_access.dart';

class MediaService {
  Future<List<int>> selectFile() async {
    final _file = await openFile();
    return await _file.readAsBytes();
  }

  // Future<List<int>> selectFiles() async {
  //   final _files = await openFiles();
  //   return await _files........readAsBytes();
  // }

  Future<List<int>> selectImage() async {
    final _file = await pickImage();
    return await _file.readAsBytes();
  }

  Future<List<int>> selectVideo() async {
    final _file = await pickVideo();
    return await _file.readAsBytes();
  }
}
