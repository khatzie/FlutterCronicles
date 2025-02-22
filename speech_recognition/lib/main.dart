import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
void main() {
  runApp(SpeechToTextApp());
}

class SpeechToTextApp extends StatelessWidget {
  const SpeechToTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      debugPrint("Microphone permission denied");
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // Open settings if permanently denied
    }
  }

  void _listen() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      _requestPermission();
      return;
    }

    try {
      if (!_isListening) {
        debugPrint("not listening");
        bool available = await _speech.initialize(
          onStatus: (status) => debugPrint('Status: $status'),
          onError: (errorNotification) {
            debugPrint('Speech Recognition Error: ${errorNotification.errorMsg}');
          },
        );


        if (!available) {
          debugPrint("Speech recognition is not available on this device.");
          return;
        }

        if (available) {
          setState(() => _isListening = true);
          _speech.listen(
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _text = result.recognizedWords;
                });
              }
            },
          );
        } else {
          debugPrint("Speech recognition is not available");
        }
      } else {
        await _speech.stop();
        if (mounted) {
          setState(() => _isListening = false);
        }
      }
    } catch (e) {
      debugPrint("Speech recognition error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Speech to Text')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _text,
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              FloatingActionButton(
                onPressed: _listen,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
