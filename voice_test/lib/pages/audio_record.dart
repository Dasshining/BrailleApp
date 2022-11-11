import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

FlutterSoundRecorder myRecorder = FlutterSoundRecorder();
late String pathToFile;

void initRecorderDirectory() async {
  Directory tempDir = await getTemporaryDirectory();
  pathToFile = '${tempDir.path}/test.mp4';
}

void record() {
  myRecorder.openRecorder();
  myRecorder.startRecorder(
    codec: Codec.pcm16,
    toFile: pathToFile,
    sampleRate: 16000,
    numChannels: 1,
  );
}

String stopRecorder() {
  myRecorder.stopRecorder();
  myRecorder.closeRecorder();
  return pathToFile;
}
