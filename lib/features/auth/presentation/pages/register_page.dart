import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instagram/features/auth/presentation/components/my_button.dart';
import 'package:instagram/features/auth/presentation/components/stext_field.dart';
import 'package:instagram/features/auth/presentation/cubit/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({
    required this.togglePages,
    super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {

 final emailController = TextEditingController();
 final nameController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  void register() {
  // prepare info
  final String name = nameController.text;
  final String email = emailController.text;
  final String pw = pwController.text;
  final String confirmPw = confirmPwController.text;

  // auth cubit
  final authCubit = context.read<AuthCubit>();
  
  // ensure the fields aren't empty
  if (email.isNotEmpty &&
      name.isNotEmpty &&
      pw.isNotEmpty &&
      confirmPw.isNotEmpty) {
    //! ensure passwords match
    if (pw == confirmPw) {
      authCubit.register(name, email, pw);
    }
    //! passwords don't match
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
    }
  }
  //! fields are empty -> display error
  else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        
        content: Text("Please complete all fields")),
      
    );
  }
}


@override 
void dispose (){
  nameController.dispose();
  emailController.dispose();
  pwController.dispose();
  confirmPwController.dispose();
  super.dispose();
}
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(
  child: Center(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //! logo
            Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            
            //!  create account msg
            Text(
              "Let's create an accout",
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 30),
            
            //! email textfield
            MyTextField(controller: nameController, hintText: 'Name', obscureText: false),
            const SizedBox(height: 15),
            MyTextField(controller: emailController, hintText: 'Email', obscureText: false),
            const SizedBox(height: 15),
            //! pw textfield
             MyTextField(controller: pwController, hintText: 'Password', obscureText: true),
            const SizedBox(height: 15),
            //! confirmpw textfield
             MyTextField(controller: confirmPwController, hintText: 'Confirm Password', obscureText: true),
            
            
             SizedBox(height: 25),
            
            //! Register button
          MyButton(onTap: register, text: 'Register'),
            SizedBox(height: 40),
            // Already a member? login now
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Text(
         "Already a member?" ,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(width: 4),
      GestureDetector(
        onTap: widget.togglePages,
        child: Text(
            " Login now",
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
),
    );
  }
}