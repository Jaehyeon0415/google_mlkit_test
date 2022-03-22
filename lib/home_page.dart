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
          Card(
            elevation: 5,
            color: Colors.blue.shade400,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            child: ListTile(
              title: const Text(
                'Body Detector',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () async {
                if (await Permission.camera.isGranted) {
                  Navigator.of(context).pushNamed('/body-detection');
                } else if (await Permission.camera.request() ==
                    PermissionStatus.granted) {
                  Navigator.of(context).pushNamed('/body-detection');
                }
              },
            ),
          ),
          // TextButton(
          //   child: Container(
          //     alignment: Alignment.center,
          //     padding: const EdgeInsets.all(12.0),
          //     color: Colors.grey.shade400,
          //     child: const Text('Body Detector'),
          //   ),
          //   onPressed: () async {
          //     if (await Permission.camera.isGranted) {
          //       Navigator.of(context).pushNamed('/body-detection');
          //     } else if (await Permission.camera.request() ==
          //         PermissionStatus.granted) {
          //       Navigator.of(context).pushNamed('/body-detection');
          //     }
          //   },
          // ),
        ],
      ),
    );
  }
}
