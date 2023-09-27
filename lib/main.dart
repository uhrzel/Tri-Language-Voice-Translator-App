import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Translator',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String recognizedText = "";
  String translatedText = "";
  late stt.SpeechToText _speech;
  bool isSpeechInitialized = false;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    isSpeechInitialized = await _speech.initialize(
      onStatus: (status) {
        // Check if the status indicates that the system is ready
        /*    if (status == stt.SpeechToTextStatus.ready) {
          print("SpeechToText initialized");
          setState(() {
            isSpeechInitialized = true;
          });
        } */
      },
    );
  }

  Future<void> startStopRecording() async {
    if (!isSpeechInitialized) {
      print("SpeechToText not available");
      // Handle the case when speech recognition is not available on the device
      return;
    }

    if (!_speech.isListening) {
      await _speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
      );
    } else {
      await _speech.stop();
      print("Listening Stopped");
      translateText(recognizedText);
    }

    setState(() {
      isRecording = !_speech.isListening;
    });
  }

  Future<void> stopRecording() async {
    if (_speech.isListening) {
      await _speech.stop();
      print("Listening Stopped");
      translateText(recognizedText);
    }

    setState(() {
      isRecording = false;
    });
  }

  Future<void> translateText(String text) async {
    final apiKey = '91c79cbfa6msh6ea3a1337107653p1f24a7jsn0b4fc372ed77';
    final response = await http.post(
      Uri.parse('https://long-translator.p.rapidapi.com/translate'),
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Host': 'long-translator.p.rapidapi.com',
        'X-RapidAPI-Key': apiKey,
      },
      body: jsonEncode({
        'q': text,
        'target': 'fil', // Target language (e.g., 'en' for English)
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        translatedText = data['data']['translations'][0]['translatedText'];
      });
    } else {
      setState(() {
        translatedText = "Translation failed.";
      });
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text Translator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Recognized Text:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              recognizedText,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'Translated Text:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              translatedText,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
            FloatingActionButton(
              onPressed: startStopRecording,
              child: Icon(isRecording ? Icons.stop : Icons.mic),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: stopRecording,
              child: Text('Stop Recording and Translate'),
            ),
          ],
        ),
      ),
    );
  }
}
