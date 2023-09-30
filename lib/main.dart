import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      debugShowCheckedModeBanner: false,
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
        /* if (status == stt.SpeechToTextStatus.ready) {
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
      _speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
      );
    } else {
      _speech.stop();
      print("Listening Stopped");
      await translateText(recognizedText);
    }

    setState(() {
      isRecording = !_speech.isListening;
    });
  }

  Future<void> stopRecording() async {
    if (_speech.isListening) {
      _speech.stop();
      print("Listening Stopped");

      // Introduce a delay before translating
      await Future.delayed(Duration(milliseconds: 500));

      if (recognizedText.isNotEmpty) {
        await translateText(recognizedText);
      } else {
        print("Recognized text is empty.");
      }
    }

    setState(() {
      isRecording = false;
    });
  }

  Future<void> translateText(String text) async {
    String apiKey = dotenv.env['API_KEY'] ?? '';
    final response = await http.get(
      Uri.parse(
          'https://google-translate112.p.rapidapi.com/translate?text=$text&target_lang=en'),
      headers: {
        'X-RapidAPI-Host': 'google-translate112.p.rapidapi.com',
        'X-RapidAPI-Key': apiKey,
      },
    );
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Perform null checks
      if (data != null && data['translation'] != null) {
        setState(() {
          translatedText = data['translation'];
        });
      } else {
        setState(() {
          translatedText = "Translation data is not in the expected format.";
        });
      }
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
