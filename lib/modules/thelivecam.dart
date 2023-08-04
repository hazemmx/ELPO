import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart' as t;

class TheCam extends StatefulWidget {
  static const routeName = '/thecam';
  const TheCam({Key? key}) : super(key: key);

  @override
  State<TheCam> createState() => _TheCamState();
}

class _TheCamState extends State<TheCam> {
  bool _isModelReady = false;
  late List<dynamic> _output = [];
  late CameraController _cameraController;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    loadModel().then((_) {
      setState(() {
        _isModelReady = true;
      });
    });
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      for (var camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          _cameraController = CameraController(camera, ResolutionPreset.medium);
          await _cameraController.initialize();
          break;
        }
      }

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> loadModel() async {
    try {
      String modelPath = 'assets/x.tflite';
      String labelsPath = 'assets/labels.txt';

      await t.Tflite.loadModel(
        model: modelPath,
        labels: labelsPath,
        isAsset: true,
      );
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  void runInferenceOnFrame(CameraImage image) async {
    if (!_isModelReady) {
      return;
    }

    try {
      var output = await t.Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );
      print(output);
      setState(() {
        _output = output!;
      });
    } catch (e) {
      print('Error running inference: $e');
    }
  }

  void startImageStream() {
    if (!_isModelReady || !_cameraController.value.isInitialized) {
      return;
    }

    _cameraController.startImageStream((image) {
      runInferenceOnFrame(image);
    });
  }

  void stopImageStream() {
    _cameraController.stopImageStream();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final previewWidth = _cameraController.value.previewSize!.height;
    final previewHeight = _cameraController.value.previewSize!.width;
    final screenWidth = screenHeight * previewWidth / previewHeight;

    return Scaffold(
      appBar: AppBar(title: Text("Live Stream Image Label")),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 30, right: 30, left: 30),
            // decoration: BoxDecoration(
            //   border: Border.all(color: Colors.grey),
            //   borderRadius: BorderRadius.circular(8),
            // ),
            child: Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              child: AspectRatio(
                aspectRatio: 1,
                child: CameraPreview(_cameraController),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 70),
                width: double.maxFinite, // Take minimum width necessary
                child: ElevatedButton(
                  onPressed: () {
                    if (_cameraController.value.isStreamingImages) {
                      stopImageStream();
                    } else {
                      startImageStream();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Set to min to take minimum width
                    children: [
                      Icon(
                        _cameraController.value.isStreamingImages
                            ? Icons.stop
                            : Icons.play_arrow,
                        size: 32,
                        color: Colors.white,
                      ),
                      SizedBox(
                          width: 10), // Add some spacing between icon and text
                      Text(
                        _cameraController.value.isStreamingImages
                            ? 'Stop Image Stream'
                            : 'Start Image Stream',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          (_output.isNotEmpty)
              ? Container(
                  margin: EdgeInsets.only(top: 10),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  // color: Colors.black54,
                  child: _output.isEmpty
                      ? Center(
                          child: Text(
                            "Please Start doing some action !",
                            style: TextStyle(fontSize: 30),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var prediction in _output)
                              Text(
                                "Current Action : " +
                                    '${_output.first['label'].toString().substring(1)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "SFPro",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                )
              : Container(
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(15),
                  //margin: EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/img/pngimg.com - question_mark_PNG87.png",
                        height: 90,
                        width: 90,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Please Start Doing Some Action ...",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: "SFPro",
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  @override
  void dispose() {
    stopImageStream();
    _cameraController.dispose();
    t.Tflite.close();
    super.dispose();
  }
}
