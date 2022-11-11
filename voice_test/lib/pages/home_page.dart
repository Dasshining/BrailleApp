import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:voice_test/pages/audio_record.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool is_Transcribing = false;
  String content = '';
  FlutterSoundRecorder myRecorder = FlutterSoundRecorder();
  String? pathToFile;

  void transcribe() async {
    setState(() {
      is_Transcribing = true;
    });
    WidgetsFlutterBinding.ensureInitialized();
    final configFile = await rootBundle
        .loadString('assets/braille-printer-app-8d73fbccf7cb.json');
    final serviceAccount = ServiceAccount.fromString(configFile);
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    final config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000,
        languageCode: 'en-US');

    final audio = await _getAudioContent('test.m4a');
    await speechToText.recognize(config, audio).then((value) {
      setState(() {
        content = value.results
            .map((e) => e.alternatives.first.transcript)
            .join('\n');
      });
    }).whenComplete(() {
      setState(() {
        is_Transcribing = false;
      });
    });
  }

  Future<List<int>> _getAudioContent(String name) async {
    String? path = pathToFile;
    return File(path as String).readAsBytesSync().toList();
  }

  @override
  void initState() {
    setPermissions();
    initRecorder();
    super.initState();
  }

  @override
  void dispose() {
    myRecorder.stopRecorder();
    super.dispose();
  }

  void setPermissions() async {
    await Permission.manageExternalStorage.request();
    await Permission.storage.request();
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
          SingleChildScrollView(
            child: Container(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: deviceHeight * 0.05,
                    ),
                    Container(
                      height: deviceHeight * 0.65,
                      width: deviceWidth * 0.75,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(173, 255, 255, 255),
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(5.0),
                      child: content == ''
                          ? Text(
                              'Your text will appear here',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Text(
                              content,
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                    SizedBox(
                      height: deviceHeight * 0.02,
                    ),
                    FloatingActionButton(
                      onPressed: () async {
                        if (myRecorder.isRecording) {
                          await stopRecorder();
                          transcribe();
                        } else {
                          await record();
                        }
                      },
                      backgroundColor: Colors.grey,
                      child: Icon(
                        !myRecorder.isRecording ? Icons.mic : Icons.stop,
                        size: 30,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Future initRecorder() async {
    Directory tempDir = await getTemporaryDirectory();
    pathToFile = '${tempDir.path}/test.mp4';
    await myRecorder.openRecorder();
  }

  Future record() async {
    await myRecorder.startRecorder(
      codec: Codec.pcm16,
      toFile: pathToFile,
      sampleRate: 16000,
      numChannels: 1,
    );
  }

  Future stopRecorder() async {
    await myRecorder.stopRecorder();
  }
}




/*
Container(
                      child: is_Transcribing
                          ? Expanded(
                              child: LoadingIndicator(
                                indicatorType: Indicator.ballPulse,
                                colors: [Colors.red, Colors.green, Colors.blue],
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 10,
                                primary: Color.fromARGB(255, 254, 254, 255),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: is_Transcribing ? () {} : transcribe,
                              child: is_Transcribing
                                  ? CircularProgressIndicator()
                                  : Text(
                                      'Record',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                            ),
                    )
*/