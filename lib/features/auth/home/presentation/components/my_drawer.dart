import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/home/presentation/components/my_drawer_tile.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:instagram/features/profile/presentation/pages/profile_page.dart';

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
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              Divider(color: Theme.of(context).colorScheme.secondary),

              //! home tile
              MyDrawerTile(title: "H O M E", icon: Icons.home, onTap: () => Navigator.of(context).pop()),

              MyDrawerTile(
                title: "P R O F I L E",
                icon: Icons.person,
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
                icon: Icons.search,
                onTap: () {},
              ),

              //! settings tile
              MyDrawerTile(
                title: "S E T T I N G S",
                icon: Icons.settings,
                onTap: () {},
              ),
              Spacer(),
              //! logout tile
              MyDrawerTile(
                title: "L O G O U T",
                icon: Icons.login,
                onTap: () {context.read<AuthCubit>().logout();},
              ),
            ],
          ),
        ), 
      ),
    );
  }
}
