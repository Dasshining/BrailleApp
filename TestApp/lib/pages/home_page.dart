import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picovoice_flutter/picovoice_error.dart';
import 'package:picovoice_flutter/picovoice_manager.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io';
import 'dart:async';
import 'package:voice_test/commands/convertToBraille.dart';
import 'package:voice_test/commands/icons_braille_icons.dart';
import 'package:rhino_flutter/rhino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
//*****Private variables*****//
  String content = '', brailleContent = '';
  final SpeechToText _speech = SpeechToText();
  bool picoVoiceActive = false;
  late Directory directory;
  late PicovoiceManager picovoiceManager;
  late FlutterTts tts;

  @override
  void initState() {
    setPermissions();
    _initPicovoice();
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
    await Permission.bluetooth.request();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: const Color.fromARGB(183, 255, 255, 255),
        elevation: 0,
        centerTitle: true,
        title: const Text(
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
            decoration: const BoxDecoration(
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
                    height: deviceHeight * 0.02,
                  ),
                  Container(
                    height: deviceHeight * 0.62,
                    width: deviceWidth * 0.75,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(173, 255, 255, 255),
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(5.0),
                      child: content == ''
                          ? const Text(
                              'Your text will appear here',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Text(
                              content,
                              style: const TextStyle(fontSize: 20),
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
                          if (_speech.isNotListening) {
                            _startListening();
                          } else if (_speech.isListening) {
                            _stopListening();
                          }
                        },
                        backgroundColor: Colors.grey,
                        child: Icon(
                          !_speech.isListening ? Icons.mic : Icons.stop,
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        width: deviceWidth * 0.1,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          _guardarArchivo();
                        },
                        backgroundColor: Colors.grey,
                        child: const Icon(
                          IconsBraille.braille,
                        ),
                      ),
                      SizedBox(
                        width: deviceWidth * 0.1,
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          speak("Imprimiendo");
                        },
                        backgroundColor: Colors.grey,
                        child: const Icon(
                          Icons.print,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _startListening() async {
    const pauseDuration = Duration(seconds: 10);
    const listenForDuration = Duration(hours: 1);

    speak("Inicia grabación");

    Future.delayed(const Duration(seconds: 2), () async {
      if (!_speech.isListening) {
        bool available = await _speech.initialize(
          onStatus: (val) => print('onStatus: $val'),
          onError: (val) => print('onError: $val'),
        );
        if (available) {
          _speech.listen(
            listenFor: listenForDuration,
            pauseFor: pauseDuration,
            onResult: (val) => setState(() {
              content = val.recognizedWords;
            }),
          );
        }
      }
    });
  }

  void _stopListening() async {
    _speech.stop();
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

  void _initPicovoice() async {
    //*****Assets files*****//
    const String accessKey =
        'WGLaXpcz3+Q8BYraUM3FM0bCZJop/jIPMF4nrwDQ4Phvlmn4QNUfXg==';
    const String KEYWORD_FILE = "ti-bob_es_android_v2_1_0.ppn";
    const String PORCUPINE_MODEL_FILE = "porcupine_params_es.pv";
    const String CONTEXT_FILE = "impresoraBraille_es_android_v2_1_0.rhn";
    const String RHINO_MODEL_FILE = "rhino_params_es.pv";

    try {
      picovoiceManager = await PicovoiceManager.create(
          accessKey,
          "assets/$KEYWORD_FILE",
          _wakeWordCallback,
          "assets/$CONTEXT_FILE",
          _inferenceCallback,
          porcupineModelPath: "assets/$PORCUPINE_MODEL_FILE",
          rhinoModelPath: "assets/$RHINO_MODEL_FILE");

      // start audio processing
      picovoiceManager.start();
    } on PicovoiceException catch (ex) {
      print(ex);
    }
    setState(() {
      picoVoiceActive = true;
    });
  }

  void _wakeWordCallback() {
    print("wake word detected!");
  }

  void _inferenceCallback(RhinoInference inference) async {
    if (inference.isUnderstood == true) {
      if (inference.intent == 'grabacion') {
        //terminar con el uso de recursos de rhino antes de inicar listeninig
        print("Iniciar grabacion");
        _startListening();
      } else if (inference.intent == 'guardar') {
        _guardarArchivo();
      } else if (inference.intent == 'imprimir') {
        speak("Imprimiendo");
        print("imprimiendo");
      } else if (inference.intent == 'dictar') {
        if (content != "") {
          speak(content);
        } else {
          speak("No hay ninguna grabación");
        }
        print("dictar");
      }
    }
    print(inference);
  }

  void freeMicResources() {
    _speech.stop();
    picovoiceManager.stop();
  }

  void speak(String appVoice) async {
    tts = FlutterTts();
    await tts.setLanguage("es-MX");
    await tts.setPitch(1);
    await tts.speak(appVoice);
  }

  void _guardarArchivo() {
    saveFile("test.txt");
    brailleContent = convertBraille(content);
    speak("Archivo guardado");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Braille Text'),
        content: SingleChildScrollView(
          child: Text(brailleContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}



  /*void _bluetoothConection() async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress("HC‐05");
      print('Connected to the device');
      connection.input!.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data); // Sending data

        if (ascii.decode(data).contains('!')) {
          connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
      });
    } catch (exception) {
      print('Cannot connect, exception occured');
    }
  }
}*/