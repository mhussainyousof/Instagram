import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:instagram/features/auth/home/presentation/components/my_drawer_tile.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/post/presentation/pages/saved_posts.dart';
import 'package:instagram/features/profile/presentation/pages/profile_page.dart';
import 'package:instagram/features/search/presentation/pages/search_page.dart';
import 'package:instagram/setting.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              //! logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Iconsax.user,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              Divider(color: Theme.of(context).colorScheme.secondary),

              //! home tile
              MyDrawerTile(title: "H O M E", icon: Iconsax.home, onTap: () => Navigator.of(context).pop()),

              MyDrawerTile(
                title: "P R O F I L E",
                icon: Iconsax.user,
                onTap: () {

                  final user = context.read<AuthCubit>().currentUser;
                  String? uid= user!.uid;


                  Navigator.of(context).pop();
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(uid:uid)));
                },
              ),

              //! search tile
              MyDrawerTile(
                title: "S E A R C H",
                icon: Iconsax.search_normal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchPage())),
              ),
              MyDrawerTile(
                title: "Saved Posts",
                icon: Iconsax.search_normal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> SavedPostsScreen())),
              ),

              //! settings tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Iconsax.setting,
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> SettingsPage())),
              ),
              Spacer(),
              //! logout tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Iconsax.logout,
                onTap: () {context.read<AuthCubit>().logout();},
              ),
            ],
          ),
        ), 
      ),
    );
  }
}
