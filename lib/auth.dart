import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:security_system/police/police_home.dart';
import 'package:security_system/user/user_home.dart';
import 'package:security_system/welcome_screen.dart';

import 'banner_screen.dart';

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  static String id = "authScreen";

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  Future<int> checkLoggedIn() async {
    // return 0: not logged in
    // return 1: logged In and is a User
    // return 2: logged In ans is a Police

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 0;
    } else {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        return 1;
      } else {
        return 2;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: checkLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == 0) {
            return const Welcome();
          } else if (snapshot.data == 1) {
            return const UserHome();
          } else {
            return const PoliceHome();
          }
        } else if (snapshot.hasError) {
          return const Welcome();
        } else {
          return const BannerScreen();
        }
      },
    );
  }
}
