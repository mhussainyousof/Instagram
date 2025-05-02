import 'package:flutter/material.dart';
import 'package:instagram/features/auth/home/presentation/components/my_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
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