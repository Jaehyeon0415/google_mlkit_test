import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gl/flutter_gl.dart';

class OpenGlPage extends StatefulWidget {
  const OpenGlPage({Key? key}) : super(key: key);

  @override
  State<OpenGlPage> createState() => _OpenGlPageState();
}

class _OpenGlPageState extends State<OpenGlPage> {
  bool isLoading = true;
  // Open GL
  late FlutterGlPlugin flutterGlPlugin;
  int? fboId;
  num dpr = 1.0;
  double width = 200;
  double height = 200;
  late Size screenSize;

  dynamic glProgram;
  dynamic sourceTexture;
  dynamic defaultFramebuffer;
  dynamic defaultFramebufferTexture;

  int n = 0;
  int t = DateTime.now().millisecondsSinceEpoch;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    initOpenGlByPlatform();
  }

  @override
  void dispose() {
    flutterGlPlugin.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('3D 아바타'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight * .5,
              color: Colors.black,
              child: isLoading
                  ? const SizedBox.shrink()
                  : flutterGlPlugin.isInitialized
                      ? Texture(textureId: flutterGlPlugin.textureId!)
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  // Open GL Functions
  void initSize(BuildContext ctx) {
    screenSize = MediaQuery.of(ctx).size;
    width = screenSize.width;
    height = screenSize.width;
    dpr = MediaQuery.of(ctx).devicePixelRatio;

    initOpenGlByPlatform();
  }

  Future<void> initOpenGlByPlatform() async {
    flutterGlPlugin = FlutterGlPlugin();
    Map<String, dynamic> options = {
      'antialias': true,
      'alpha': false,
      'width': width.toInt(),
      'height': height.toInt(),
      'dpr': dpr,
    };

    await flutterGlPlugin.initialize(options: options);

    debugPrint('OpenGl textureId: ${flutterGlPlugin.textureId}');

    setState(() {});

    await Future.delayed(const Duration(milliseconds: 100));

    _setUp();
  }

  void _setUp() async {
    if (!kIsWeb) {
      await flutterGlPlugin.prepareContext();

      var gl = flutterGlPlugin.gl;
      var size = gl.getParameter(gl.MAX_TEXTURE_SIZE);

      // debugPrint('Setup MAX_TEXTURE_SIZE: $size');

      setupDefaultFBO();
      sourceTexture = defaultFramebufferTexture;
      debugPrint('sourceTexture: $sourceTexture');
    }

    prepare();

    setState(() {
      isLoading = false;
    });
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      render();
    });
  }

  setupDefaultFBO() {
    final gl = flutterGlPlugin.gl;
    int glWidth = (width * dpr).toInt();
    int glHeight = (height * dpr).toInt();

    defaultFramebuffer = gl.createFramebuffer();
    defaultFramebufferTexture = gl.createTexture();
    gl.activeTexture(gl.TEXTURE0);

    gl.bindTexture(gl.TEXTURE_2D, defaultFramebufferTexture);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, glWidth, glHeight, 0, gl.RGBA,
        gl.UNSIGNED_BYTE, null);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    gl.bindFramebuffer(gl.FRAMEBUFFER, defaultFramebuffer);
    gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D,
        defaultFramebufferTexture, 0);
  }

  render() async {
    final gl = flutterGlPlugin.gl;

    int current = DateTime.now().millisecondsSinceEpoch;

    num blue = sin((current - t) / 500);

    // Clear canvas
    gl.clearColor(1.0, 0.0, blue, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);

    gl.drawArrays(gl.TRIANGLES, 0, n);

    debugPrint(" render n: $n ");

    gl.finish();

    if (!kIsWeb) {
      flutterGlPlugin.updateTexture(sourceTexture);
    }
  }

  prepare() {
    final gl = flutterGlPlugin.gl;

    String version = "300 es";

    var vs = """#version $version
      #define attribute in
      #define varying out
    attribute vec3 a_Position;
    void main() {
        gl_Position = vec4(a_Position, 1.0);
    }
    """;

    var fs = """#version $version
    #define varying in
    out highp vec4 pc_fragColor;
    #define gl_FragColor pc_fragColor
    void main() {
        gl_FragColor = vec4(1.0, 1.0, 0.0, 1.0);
    }
    """;

    if (!initShaders(gl, vs, fs)) {
      debugPrint('Failed to intialize shaders.');
      return;
    }

    // Write the positions of vertices to a vertex shader
    n = initVertexBuffers(gl);
    if (n < 0) {
      debugPrint('Failed to set the positions of the vertices');
      return;
    }
  }

  initVertexBuffers(gl) {
    // Vertices
    var dim = 3;
    var vertices = Float32List.fromList([
      -0.5, -0.5, 0, // Vertice #2
      0.5, -0.5, 0, // Vertice #3
      0, 0.5, 0, // Vertice #1
    ]);

    var vao = gl.createVertexArray();

    gl.bindVertexArray(vao);

    // Create a buffer object
    var vertexBuffer = gl.createBuffer();
    if (vertexBuffer == null) {
      debugPrint('Failed to create the buffer object');
      return -1;
    }
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);

    gl.bufferData(gl.ARRAY_BUFFER, vertices.length, vertices, gl.STATIC_DRAW);

    // Assign the vertices in buffer object to a_Position variable
    var a_Position = gl.getAttribLocation(glProgram, 'a_Position');
    if (a_Position < 0) {
      debugPrint('Failed to get the storage location of a_Position');
      return -1;
    }
    gl.vertexAttribPointer(
        a_Position, dim, gl.FLOAT, false, Float32List.bytesPerElement * 3, 0);
    gl.enableVertexAttribArray(a_Position);

    // Return number of vertices
    return vertices.length ~/ dim;
  }

  initShaders(gl, vs_source, fs_source) {
    // Compile shaders
    var vertexShader = makeShader(gl, vs_source, gl.VERTEX_SHADER);
    var fragmentShader = makeShader(gl, fs_source, gl.FRAGMENT_SHADER);

    // Create program
    glProgram = gl.createProgram();

    // Attach and link shaders to the program
    gl.attachShader(glProgram, vertexShader);
    gl.attachShader(glProgram, fragmentShader);
    gl.linkProgram(glProgram);
    var res = gl.getProgramParameter(glProgram, gl.LINK_STATUS);
    debugPrint(" initShaders LINK_STATUS _res: $res ");
    if (res == false || res == 0) {
      debugPrint("Unable to initialize the shader program");
      return false;
    }

    // Use program
    gl.useProgram(glProgram);

    return true;
  }

  makeShader(gl, src, type) {
    var shader = gl.createShader(type);
    gl.shaderSource(shader, src);
    gl.compileShader(shader);
    var res = gl.getShaderParameter(shader, gl.COMPILE_STATUS);
    if (res == 0 || res == false) {
      debugPrint("Error compiling shader: ${gl.getShaderInfoLog(shader)}");
      return;
    }
    return shader;
  }
}
