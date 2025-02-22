import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Recognition',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraCaptureScreen(),
    );
  }
}

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  _CameraCaptureScreenState createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  List? _results;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
     await Tflite.loadModel(
        model: "assets/mobilenet_v2_1.0_224.tflite",
        labels: "assets/labels_mobilenet.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }

  Future<List?> classifyImage(String imagePath) async {
    print(imagePath);

    var recognitions = await Tflite.runModelOnImage(
        path: imagePath,   // required
        imageMean: 0.0,   // defaults to 117.0
        imageStd: 255.0,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        threshold: 0.2,   // defaults to 0.1
        asynch: true      // defaults to true
    );
    print(recognitions);
    return recognitions;
  }

  // Function to pick an image from the camera
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
      _classifyImage(image.path);
    }
  }

  Future<void> _classifyImage(String imagePath) async {
    List? results = await classifyImage(imagePath);
    setState(() {
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Recognition"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Open Camera"),
            ),
            SizedBox(height: 20),
            _image == null
                ? Text("No image captured")
                : Image.file(File(_image!.path)),
            SizedBox(height: 20),
            _results != null
                ? Text("Results: $_results")
                : Container(),
          ],
        ),
      ),
    );
  }
}


