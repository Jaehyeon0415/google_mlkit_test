import 'dart:typed_data';

import 'package:body_detection/body_detection.dart';
import 'package:body_detection/models/body_mask.dart';
import 'package:body_detection/models/image_result.dart';
import 'package:body_detection/models/pose.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';
import 'dart:ui' as ui;

import 'package:google_mlkit_test/body_detector/pose_mask_painter.dart';

class BodyDetectorPage extends StatefulWidget {
  const BodyDetectorPage({Key? key}) : super(key: key);

  @override
  State<BodyDetectorPage> createState() => _BodyDetectorPageState();
}

class _BodyDetectorPageState extends State<BodyDetectorPage> {
  bool _isLoading = true;

  // Body Detection
  bool _isDetectingPose = true;
  bool _isDetectingBodyMask = true;
  Image? _selectedImage;
  Pose? _detectedPose;
  ui.Image? _maskImage;
  Image? _cameraImage;
  Size _imageSize = Size.zero;

  @override
  void initState() {
    _startCameraStream();
    super.initState();
  }

  @override
  void dispose() {
    _stopCameraStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Body Detector'),
      ),
      body: _isLoading
          ? const CircularProgressIndicator()
          : Center(
              child: ClipRect(
                child: CustomPaint(
                  foregroundPainter: PoseMaskPainter(
                    pose: _detectedPose,
                    mask: _maskImage,
                    imageSize: _imageSize,
                  ),
                  child: _cameraImage,
                ),
              ),
            ),
    );
  }

  // Body Detection Functions
  Future<void> _startCameraStream() async {
    await BodyDetection.startCameraStream(
      onFrameAvailable: _handleCameraImage,
      onPoseAvailable: (pose) {
        if (!_isDetectingPose) return;
        _handlePose(pose);
      },
      onMaskAvailable: (mask) {
        if (_isDetectingBodyMask) return;
        _handleBodyMask(mask);
      },
    );
    await BodyDetection.enablePoseDetection();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _stopCameraStream() async {
    await BodyDetection.stopCameraStream();
  }

  void _handleCameraImage(ImageResult result) {
    if (!mounted) return;

    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    final image = Image.memory(
      result.bytes,
      gaplessPlayback: true,
      fit: BoxFit.contain,
    );

    setState(() {
      _cameraImage = image;
      _imageSize = result.size;
    });
  }

  void _handlePose(Pose? pose) {
    if (!mounted) return;

    setState(() {
      _detectedPose = pose;
    });
  }

  void _handleBodyMask(BodyMask? mask) {
    if (!mounted) return;

    if (mask == null) {
      setState(() {
        _maskImage = null;
      });
      return;
    }

    final bytes = mask.buffer
        .expand(
          (element) => [0, 0, 0, (element * 255).toInt()],
        )
        .toList();
    ui.decodeImageFromPixels(
      Uint8List.fromList(bytes),
      mask.width,
      mask.height,
      ui.PixelFormat.rgba8888,
      (image) {
        setState(() {
          _maskImage = image;
        });
      },
    );
  }
}
