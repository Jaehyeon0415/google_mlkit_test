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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('3D 아바타 데모'),
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
          Card(
            elevation: 5,
            color: Colors.blue.shade400,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            child: ListTile(
              onTap: () => Navigator.of(context).pushNamed('/open-gl'),
              title: const Text(
                '3D 아바타',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Card(
            elevation: 5,
            color: Colors.blue.shade400,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
            child: ListTile(
              onTap: () => Navigator.of(context).pushNamed('/open-gl-test'),
              title: const Text(
                '3D 아바타 테스트',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
