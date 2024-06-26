import 'package:flutter/material.dart';
import '../../screens/login_screen.dart';
import '../../screens/register_screen.dart';

class LoginOrRegisterPage extends StatefulWidget {
   const LoginOrRegisterPage({Key? key}) : super(key: key);

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages(){
    setState((){
      showLoginPage = !showLoginPage;
    });
  }

 @override
  Widget build(BuildContext content){
    if (showLoginPage){
      return LoginPage(
      onTap: togglePages,
      );
    }else{
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}