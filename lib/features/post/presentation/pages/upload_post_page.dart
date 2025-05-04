import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/domain/entity/app_user.dart';
import 'package:instagram/features/auth/presentation/components/stext_field.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:instagram/features/post/domain/entity/post.dart';
import 'package:instagram/features/post/presentation/cubit/post_cubit.dart';
import 'package:instagram/features/post/presentation/cubit/post_state.dart';
import 'package:flutter/foundation.dart';  


class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});
  @override
  State<UploadPostPage> createState() => _UploadPostPageState();

}
class _UploadPostPageState extends State<UploadPostPage> {

  PlatformFile? imagePickerFile;
  Uint8List? webImage;
  final textController = TextEditingController();

  //! Current user
AppUser? currentUser;

@override
void initState() {
    super.initState();
    getCurrentUser();
}

//! Get current user
void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
}


 Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickerFile = result.files.first;
        if (kIsWeb) {
          webImage =
              imagePickerFile!.bytes; 
        }
      });
    }
  }

  //! create & upload post
void uploadPost() {
    // check if both image and caption are provided
    if (imagePickerFile == null || textController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Both image and caption are required")),
        );
        return;
    }
    //! create a new post object
final newPost = Post(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    userId: currentUser!.uid,
    userName: currentUser!.name,
    text: textController.text,
    imageUrl: '',
    timestamp: DateTime.now(),
); // Post

// post cubit
final postCubit = context.read<PostCubit>();

 // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickerFile?.bytes);
    }
    // mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickerFile?.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
   return BlocConsumer<PostCubit, PostState>(
  builder: (context, state) {
    // loading or uploading..
    if (state is PostsLoading || state is PostUploading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ), // Center
      ); // Scaffold
    }
    
    // build upload page
    return buildUploadPage();
  },
  listener: (context, state){
    if(state is PostsLoaded){
      Navigator.pop(context);
    }
  },
); // BlocConsumer
  }

Widget buildUploadPage() {
  return Scaffold(
    // APP BAR
    appBar: AppBar(
      title: const Text("Create Post"),
      foregroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(onPressed: uploadPost, icon: Icon(Icons.upload))
      ],
    ),

    //! BODY
    body: Center(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            //! image preview for web
            if (kIsWeb && webImage != null) Image.memory(webImage!),
        
            //! image preview for mobile
            if (!kIsWeb && imagePickerFile != null)
              Image.file(File(imagePickerFile!.path!)),
        
            //! pick image button
            MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text("Pick Image"),
            ),
            MyTextField(controller: textController, hintText: 'Caption', obscureText: false),
            SizedBox(height: 20)
          ],
        ),  
      ),
    ), 
  ); 
}
  
}

