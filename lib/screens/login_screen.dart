import 'package:chat1/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat1/components/rounded_button.dart';
import 'package:chat1/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool spiner = false;
  String inputEmail;
  String inputPassword;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: spiner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
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
                textAlign: TextAlign.center,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  inputEmail = value;
                },
                decoration: KtextFilddecoration.copyWith(
                    hintText:
                        'Enter your emil'), //, icon: Icon(Icons.email), iconColor: Colors.blueAccent),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                textAlign: TextAlign.center,
                obscureText: true,
                onChanged: (value) {
                  inputPassword = value;
                },
                decoration: KtextFilddecoration.copyWith(
                    hintText:
                        'Enter your password'), //,icon: Icon(Icons.lock), iconColor: Colors.blueAccent),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedBotton(
                title: 'Log In',
                color: Colors.lightBlueAccent,
                onpressed: () async {
                  setState(() {
                    spiner = true;
                  });
                  try {
                    final currentUser = await _auth.signInWithEmailAndPassword(
                        email: inputEmail, password: inputPassword);
                    if (currentUser != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    setState(() {
                      spiner=false;
                    });
                  } catch (e) {
                    print(e);
                  }

                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
