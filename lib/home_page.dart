import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(12.0),
              color: Colors.grey.shade400,
              child: const Text('Body Detector'),
            ),
            onPressed: () async {
              if (await Permission.camera.isGranted) {
                Navigator.of(context).pushNamed('/body-detection');
              } else if (await Permission.camera.request() ==
                  PermissionStatus.granted) {
                Navigator.of(context).pushNamed('/body-detection');
              }
            },
          ),
        ],
      ),
    );
  }
}
