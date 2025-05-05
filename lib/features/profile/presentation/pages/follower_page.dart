import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/profile/domain/entity/profile_user.dart';
import 'package:instagram/features/profile/presentation/components/user_tile.dart';
import 'package:instagram/features/profile/presentation/cubit/profile_cubit.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          
          title: const Text('Followers & Following'),
          bottom:  TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
         children: [
          buildUserList(followers, 'No followerxs', context),
          buildUserList(followers, 'No following', context),

         ],
      ),
    ));
  }

  Widget buildUserList(
  List<String> uids, 
  String emptyMessage, 
  BuildContext context,
) {
  return uids.isEmpty
      ? Center(child: Text(emptyMessage))
      : ListView.builder(
          itemCount: uids.length,
          itemBuilder: (context, index) {
            // get each uid
            final uid = uids[index];
            
            return FutureBuilder(
              future: context.read<ProfileCubit>().getUserProfile(uid),
              builder: (context, snapshot) {
                // user loaded
                if (snapshot.hasData) {
                  final user = snapshot.data!; 
                  return UserTile(user: user,
);
                }
                // loading
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    title: Text("Loading..."),
                    leading: CircularProgressIndicator(),
                  );
                }
                // error or not found
                else {
                  return ListTile(
                    title: Text("User not found"),
                    subtitle: Text(uid),
                  );
                }
              },
            );
          },
        );
}
}