import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = '/registration';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  bool busy = false;
  String email;
  String password;
  String passwordCheck;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: busy,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'lightning',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardAppearance: Brightness.dark,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
                decoration: kRegisterTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardAppearance: Brightness.dark,
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kRegisterTextFieldDecoration.copyWith(
                    hintText: 'Enter Your Password'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  passwordCheck = value;
                },
                decoration: kRegisterTextFieldDecoration.copyWith(
                    hintText: 'Re-type Password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Hero(
                  tag: 'registerButton',
                  child: RoundedButton(
                    title: 'Register',
                    onPressed: () async {
                      setState(() {
                        busy = true;
                      });
                      if (password == passwordCheck) {
                        try {
                          final newUser =
                              await _auth.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          if (newUser != null) {
                            setState(() {
                              busy = false;
                            });
                            Navigator.pushNamed(context, UsersScreen.id);
                          }
                        } catch (e) {
                          setState(() {
                            busy = false;
                          });
                          print(e);
                        }
                      } else {
                        setState(() {
                          busy = false;
                        });
                        print('passwords don\'t match');
                      }
                    },
                    color: kRegisterButtonColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
