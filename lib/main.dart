import 'package:flutter/material.dart';
import 'package:google_mlkit_test/body_detector/body_detector_page.dart';
import 'package:google_mlkit_test/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter google-ml-kit demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/body-detection': (context) => const BodyDetectorPage(),
      },
    );
  }
}
