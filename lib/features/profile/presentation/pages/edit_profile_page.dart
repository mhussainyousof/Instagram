import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/presentation/components/stext_field.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
   final  bioTextController = TextEditingController();



  //! update profile button pressed
void updateProfile() async {
    // profile cubit
    final profileCubit = context.read<ProfileCubit>();
    if (bioTextController.text.isNotEmpty) {
        profileCubit.updateProfile(
            uid: widget.user.uid,
            newBio: bioTextController.text,
        );
    }
}

// BUILD UI
@override
Widget build(BuildContext context) {
    // SCAFFOLD
    return BlocConsumer<ProfileCubit, ProfileState>( 
        builder: (context, state) {
         
            if(state is ProfileLoading){
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      Text('Uploading...')
                    ],
                  ),
                ),
              );
            }else{
              return buildEditPage();
            }
        },
        listener: (context, state) {
          if(state is ProfileLoaded){
            Navigator.pop(context);
          }
        }
    );
}

Widget buildEditPage({double uploadProgress = 0.0}) {
   return Scaffold(
    appBar: AppBar(
      title: Text('Edit Profile'),
      foregroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(onPressed: updateProfile, icon: Icon(Icons.upload))
      ],
    ),
    body: Column(
      children: [
        Text('Bio'),
        SizedBox(height: 10),
        Padding(padding: EdgeInsets.symmetric(horizontal: 25.0),
        child: MyTextField(controller: bioTextController, hintText: widget.user.bio, obscureText: false),
        
        )
      ],
    ),
   );
}
}