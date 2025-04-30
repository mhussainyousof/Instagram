import 'package:flutter/material.dart';
import 'package:instagram/features/auth/presentation/components/my_button.dart';
import 'package:instagram/features/auth/presentation/components/stext_field.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({
    required this.togglePages,
    super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emainController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
  child: Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // logo
          Icon(
            Icons.lock_open_rounded,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          
          // welcome back msg
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 30),
          
          // email textfield
          MyTextField(controller: emainController, hintText: 'Email', obscureText: false),
          const SizedBox(height: 15),
          // pw textfield
           MyTextField(controller: passwordController, hintText: 'Password', obscureText: true),
          
          
           SizedBox(height: 25),
          
          // login button
        MyButton(onTap: (){}, text: 'Login'),
          SizedBox(height: 40),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
       "Don't have an account?" ,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    const SizedBox(width: 4),
    GestureDetector(
      onTap: widget.togglePages,
      child: Text(
          " Register now",
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),

        ],
      ),
    ),
  ),
),
    );
  }
}