import 'dart:typed_data';

abstract class StorageRepo {
  //! Upload profile image from a file path (for mobile)
  Future<String?> uploadProfileImageMobile(String path, String fileName);

  //! Upload profile image from bytes (for web)
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName);
}