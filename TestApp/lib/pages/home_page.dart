import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'dart:io';
import 'dart:async';
import 'package:voice_test/pages/saveScreen.dart';
import 'package:voice_test/commands/convertToBraille.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String content = '';
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  late Directory directory;
  String savePageTitle = "ScreenTwo";
  /*Future<List<int>> _getAudioContent(String name) async {
    String? path = pathToFile;
    return File(path as String).readAsBytesSync().toList();
  }*/

  @override
  void initState() {
    setPermissions();
    super.initState();
    print("INIT");
  }

  @override
  void dispose() {
    super.dispose();
    print("CLOSE");
  }

  void setPermissions() async {
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Color.fromARGB(183, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'TVOB',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontSize: 45,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0.8),
              image: const DecorationImage(
                  image: AssetImage("resources/fondo.jpg"), fit: BoxFit.fill),
            ),
          ),
          Container(
            height: deviceHeight,
            width: deviceWidth,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(50),
                topLeft: Radius.circular(50),
              ),
            ),
            child: Center(
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: deviceHeight * 0.02,
                    ),
                    Container(
                      height: deviceHeight * 0.65,
                      width: deviceWidth * 0.75,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(173, 255, 255, 255),
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(5.0),
                          child: content == ''
                              ? const Text(
                                  'Your text will appear here',
                                  style: TextStyle(color: Colors.grey),
                                )
                              : Text(
                                  content,
                                  style: TextStyle(fontSize: 20),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: deviceHeight * 0.02,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            _listen();
                          },
                          backgroundColor: Colors.grey,
                          child: Icon(
                            !_speech.isListening ? Icons.mic : Icons.stop,
                            size: 30,
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            content = convertBraille(content);
                            saveFile("test.txt");
                          },
                          backgroundColor: Colors.grey,
                          child: Icon(
                            Icons.save_alt_outlined,
                            //buttonTest ? Icons.book : Icons.menu,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Braille Text'),
                            content: Text(content),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Ok'),
                              ),
                            ],
                          ),
                        );
                      },
                      backgroundColor: Colors.grey,
                      child: Icon(
                        Icons.save_alt_outlined,
                        //buttonTest ? Icons.book : Icons.menu,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _listen() async {
    const pauseDuration = Duration(seconds: 10);
    const listenForDuration = Duration(hours: 1);
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          listenFor: listenForDuration,
          pauseFor: pauseDuration,
          onResult: (val) => setState(() {
            content = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<String> getPath(String fileName) async {
    directory = await getExternalStorageDirectory() as Directory;
    String newPath = '';
    print(directory);
    List<String> paths = directory.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }
    newPath = "$newPath/BraileTextFiles";
    directory = Directory(newPath);
    print(directory.path);

    ///storage/emulated/0/BraileTextFiles
    if (await directory.exists()) {
    } else {
      directory.create();
    }

    String filePath = "$newPath/$fileName";

    return filePath;
  }

  void saveFile(String fileName) async {
    File file = File(await getPath(fileName));
    file.writeAsString(content);
    print("file Saved");
  }

  Future<String> readFile(String fileName) async {
    File file = File(await getPath(fileName));
    String fileContent = await file.readAsString();
    print("You should be able to see to content of the file in this");
    return fileContent;
  }
}
