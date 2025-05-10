import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';


class EditProfilePage extends StatefulWidget {
  final ProfileUser user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final bioTextController = TextEditingController();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    bioTextController.text = widget.user.bio;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) webImage = imagePickedFile!.bytes;
      });
    }
  }

void updateProfile() async {
    if (_isUpdating) return;
    
    setState(() => _isUpdating = true);
    
    // Get these values before any async operation
    final profileCubit = context.read<ProfileCubit>();
    final String uid = widget.user.uid;
    final String? newBio = bioTextController.text.trim().isNotEmpty 
        ? bioTextController.text.trim() 
        : null;

    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    try {
      if (imagePickedFile != null || newBio != null) {
        await profileCubit.updateProfile(
          uid: uid,
          newBio: newBio,
          imageMobilePath: imageMobilePath,
          imageWebBytes: imageWebBytes,
        );
      }

      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      // Always set state to false when done
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : updateProfile,
            child: Text(
              'Done',
              style: TextStyle(
                color: _isUpdating ? Colors.grey : Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Picture Section
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(
                        child: _buildProfileImage(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          // color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        color: Colors.deepPurpleAccent
                        ),
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Icon(
                            color: Colors.white,
                            size: 15,
                            Iconsax.camera))
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Bio Section
            TextFormField(
              controller: bioTextController,
              maxLines: 3,
              maxLength: 150,
              decoration: InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell your story...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          
            
            if (_isUpdating) ...[
              const SizedBox(height: 20),
              const LinearProgressIndicator(),
              const SizedBox(height: 10),
              const Text('Updating profile...'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (!kIsWeb && imagePickedFile != null) {
      return Image.file(
        File(imagePickedFile!.path!),
        fit: BoxFit.cover,
      );
    } else if (kIsWeb && webImage != null) {
      return Image.memory(
        webImage!,
        fit: BoxFit.cover,
      );
    } else {
      return CachedNetworkImage(
        imageUrl: widget.user.profileImageUrl,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.person,
          size: 40,
          color: Colors.grey.shade400,
        ),
        fit: BoxFit.cover,
      );
    }
  }

  @override
  void dispose() {
    bioTextController.dispose();
    super.dispose();
  }
}
      
