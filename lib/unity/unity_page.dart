import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class UnityPage extends StatefulWidget {
  const UnityPage({Key? key}) : super(key: key);

  @override
  State<UnityPage> createState() => _UnityPageState();
}

class _UnityPageState extends State<UnityPage> {
  UnityWidgetController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Unity Demo'),
      ),
      body: SafeArea(
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: UnityWidget(
            onUnityCreated: (c) async {
              debugPrint('# onUnityCreated!');
              controller = c;
            },
          ),
        ),
      ),
    );
  }
}
