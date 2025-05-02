import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:instagram/features/cloudanity/domain/storage_repo.dart';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:typed_data';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';


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
