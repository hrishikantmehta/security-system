import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:security_system/banner_screen.dart';
import 'package:security_system/police/police_home.dart';
import 'package:security_system/police/police_login.dart';
import 'package:security_system/user/user_home.dart';
import 'package:security_system/user/user_login.dart';

class Welcome extends StatefulWidget {
  static String id = "welcomeScreen";

  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('images/house.png'),
              width: 100,
            ),
            SizedBox(
              height: 20,
            ),
            const Text(
              'Login As',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, PoliceLogin.id);
              },
              child: const Text(
                'Police',
              ),
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.greenAccent,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize: Size(150, 40), //////// HERE
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, UserLogin.id);
              },
              child: const Text(
                'User',
              ),
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.greenAccent,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize: Size(150, 40), //////// HERE
              ),
            ),
          ],
        ),
      ),
    );
  }
}
