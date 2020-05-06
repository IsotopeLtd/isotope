import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class CloudStorageService {
  Future<CloudStorageResult> uploadImage({@required List<int> imageBytesToUpload, @required String name}) async {
    var imageId = name + DateTime.now().millisecondsSinceEpoch.toString();
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(imageId);

    StorageUploadTask uploadTask = firebaseStorageRef.putData(Uint8List.fromList(imageBytesToUpload));
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;

    var downloadUrl = await storageSnapshot.ref.getDownloadURL();

    if (uploadTask.isComplete) {
      var url = downloadUrl.toString();

      return CloudStorageResult(
        imageUrl: url,
        imageId: imageId,
      );
    }

    return null;
  }

  Future deleteImage(String imageId) async {
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(imageId);

    try {
      await firebaseStorageRef.delete();
      return true;
    } catch (e) {
      return e.toString();
    }
  }
}

class CloudStorageResult {
  final String imageUrl;
  final String imageId;

  CloudStorageResult({this.imageUrl, this.imageId});
}
