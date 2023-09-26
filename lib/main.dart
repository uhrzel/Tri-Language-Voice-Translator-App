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

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech.listen(
      onResult: (result) {
        setState(() {
          recognizedText = result.recognizedWords;
        });
      },
    );
  }

/*   Future<void> startRecording() async {
    final status = await Permission.microphone.request();

    if (status.isGranted) {
      await _speech.listen(
        onResult: (result) {
          print("Listening Started");
        },
      );
    } else {
      print("Microphone permission not granted");
    }
  } */

  Future<void> stopRecording() async {
    if (_speech.isListening) {
      await _speech.stop();
      print("Listening Stopped");
      translateText(recognizedText);
    }
  }

  Future<void> translateText(String text) async {
    final apiKey = 'YOUR_RAPIDAPI_KEY';
    final response = await http.post(
      Uri.parse(
          'https://google-translate1.p.rapidapi.com/language/translate/v2'),
      headers: {
        'Content-Type': 'application/json',
        'X-RapidAPI-Host': 'google-translate1.p.rapidapi.com',
        'X-RapidAPI-Key': apiKey,
      },
      body: jsonEncode({
        'q': text,
        'target': 'en', // Target language (e.g., 'en' for English)
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
            /*   ElevatedButton(
              onPressed: startRecording,
              child: Text('Start Recording'),
            ), */
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
