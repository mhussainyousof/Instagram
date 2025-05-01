import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){context.read<AuthCubit>().logout();}, icon: Icon(Icons.logout))
        ],
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to your Home Page!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}