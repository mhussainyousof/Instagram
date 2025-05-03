import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/features/cloudanity/domain/storage_repo.dart';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Mobile platform - upload from file path
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  // Web platform - upload from bytes (corrected Uint8List type)
  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "profile_images");
  }

  /* ========== HELPER METHODS ========== */

  //! Upload from file path (for mobile)
  Future<String?> _uploadFile(
    String path, 
    String fileName, 
    String folder
  ) async {
    try {
      final file = File(path);
      final ref = storage.ref('$folder/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Upload from bytes (for web)
  Future<String?> _uploadFileBytes(
    Uint8List fileBytes,
    String fileName,
    String folder
  ) async {
    try {
      final ref = storage.ref('$folder/$fileName');
      await ref.putData(fileBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}


class CloudinaryStorageRepo implements StorageRepo {
  final CloudinaryPublic _cloudinary = 
      CloudinaryPublic('dqdl8nui0', 'ShopEasee', cache: false);

  // ========== Mobile (File Path) ==========
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          path,
          folder: "profile_images",
          publicId: fileName, // Use UID or unique name
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }

  // ========== Web (Uint8List Bytes) ==========
  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) async {
    try {
      final tempFile = XFile.fromData(fileBytes, name: fileName);

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          tempFile.path,
          folder: "profile_images",
          publicId: fileName,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      return null;
    }
  }
}
