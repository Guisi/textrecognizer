import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Recognizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Text Recognizer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _file;
  String _recognizedText = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void openImagePressed() async {
    setState(() {
      _recognizedText = "Loading ...";
    });

    try {
      //var file = await ImagePicker.pickImage(source: ImageSource.camera);
      var file = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        _file = file;
      });

      // create vision image from that file
      final FirebaseVisionImage visionImage =
          FirebaseVisionImage.fromFile(_file);

      // create detector index
      final TextRecognizer textRecognizer =
          FirebaseVision.instance.textRecognizer();

      // find text in image
      final VisionText visionText =
          await textRecognizer.processImage(visionImage);

      setState(() {
      _recognizedText = visionText.text;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = new GlobalKey<ScaffoldState>();

    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Center(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(child: _file != null ? Image.file(_file) : Container()),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: new GestureDetector(
                      child: new Text(_recognizedText),
                      onLongPress: () {
                        Clipboard.setData(new ClipboardData(text: _recognizedText));
                        key.currentState.showSnackBar(
                            new SnackBar(content: new Text("Copied to Clipboard"),));
                      },
                    )
                )]
              )
            )
        ],
      )),
      floatingActionButton: new FloatingActionButton(
        onPressed: openImagePressed,
        child: new Icon(Icons.camera),
      ),
    );
  }
}
