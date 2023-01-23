import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:security_system/auth.dart';
import 'package:security_system/globals.dart';
import 'package:security_system/police/available_request.dart';
import 'package:security_system/police/available_request_on_map.dart';
import 'package:security_system/police/police_home.dart';
import 'package:security_system/police/police_login.dart';
import 'package:security_system/police/police_signup.dart';
import 'package:security_system/user/make_request.dart';
import 'package:security_system/user/my_profile.dart';
import 'package:security_system/user/my_request.dart';
import 'package:security_system/user/user_home.dart';
import 'package:security_system/user/user_login.dart';
import 'package:security_system/user/user_signup.dart';
import 'package:security_system/user/choose_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:security_system/welcome_screen.dart';
import 'package:security_system/banner_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: Auth(),
      routes: {
        Welcome.id: (context) => const Welcome(),
        BannerScreen.id: (context) => const BannerScreen(),
        Auth.id: (context) => const Auth(),
        UserLogin.id: (context) => const UserLogin(),
        UserSignUp.id: (context) => const UserSignUp(),
        UserHome.id: (context) => const UserHome(),
        PoliceLogin.id: (context) => const PoliceLogin(),
        PoliceSignUp.id: (context) => const PoliceSignUp(),
        PoliceHome.id: (context) => const PoliceHome(),
        ChooseLocation.id: (context) => const ChooseLocation(),
        MakeRequest.id: (context) => const MakeRequest(),
        MyRequests.id: (context) => const MyRequests(),
        AvailableRequest.id: (context) => const AvailableRequest(),
      },
    );
  }
}
