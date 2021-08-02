import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  File _image;
  List _output;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    _isLoading = true;
    super.initState();
    loadModel().then((val) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Covid19Detector"),
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image == null ? Container() : Image.file(_image),
                  SizedBox(
                    height: 16,
                  ),
                  _output == null
                      ? Text("")
                      : Text(
                          "${_output[0]["label"]}",
                          style: TextStyle(fontSize: 22),
                        )
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          chooseImage();
        },
        child: Icon(Icons.image),
      ),
    );
  }

  chooseImage() async {
    //var picker = ImagePicker();
    var img = await _picker.pickImage(source: ImageSource.gallery);
    var image = File(img.path);
    if (image == null) return null;

    setState(() {
      _image = image;
    });

    runModelOnImage(image);
  }

  runModelOnImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.5);
    setState(() {
      _isLoading = false;
      _output = output;
    });
  }

  Future loadModel() async {
    await Tflite.loadModel(
        model: "assets/My_TFlite_Model.tflite", labels: "assets/labels.txt");
  }
}
