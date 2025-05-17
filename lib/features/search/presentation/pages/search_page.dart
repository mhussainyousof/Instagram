import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/profile/presentation/components/user_tile.dart';
import 'package:instagram/features/search/presentation/cubit/search_cubit.dart';
import 'package:instagram/features/search/presentation/cubit/search_states.dart';
import 'package:instagram/responsive/constrained_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final SearchCubit searchCubit;

  @override
  void initState() {
    super.initState();
    searchCubit = context.read<SearchCubit>();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    searchCubit.searchUsers(searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(  
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(
  builder: (context, state) {
    //! Loaded state
    if (state is SearchLoaded) {
      // No users found
      if (state.users.isEmpty) {
        return const Center(child: Text("No users found"));
      }
      // Display users list
      return ListView.builder(
        itemCount: state.users.length,
        itemBuilder: (context, index) {
          final user = state.users[index];
          return UserTile(
            showFollowButton: false,
            user: user!);
        },
      );
    }
    // Loading state
    else if (state is SearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Error state
    else if (state is SearchError) {
      return Center(child: Text(state.message));
    }
    // Initial/default state
    return const Center(child: Text("Start typing to search"));
  },
),
    );
  }
}