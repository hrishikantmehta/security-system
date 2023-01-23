import 'package:flutter/material.dart';

class BannerScreen extends StatefulWidget {
  static String id = "bannerScreen";
  const BannerScreen({Key? key}) : super(key: key);

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('images/house.png'),
              width: 100,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              'Welcome to Security System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.green,
    );
  }
}
