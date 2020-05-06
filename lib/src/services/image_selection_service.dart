import 'package:file_access/file_access.dart';

class ImageSelectionService {
  Future<List<int>> selectImage() async {
    final _file = await pickImage();
    return await _file.readAsBytes();
  }
}
