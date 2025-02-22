import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(ImageApp());
}

class ImageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageScreen(),
    );
  }
}

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _imageUrl;
  bool _isLoading = false;
  String? _error;

  void _loadImage() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String imageUrl = await generateImage(_controller.text);
      setState(() {
        _imageUrl = imageUrl;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to generate image. Please try again.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Image Generator")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "What image do you want to generate?",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _loadImage,
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : _error != null
                    ? Text(_error!, style: TextStyle(color: Colors.red))
                    : _imageUrl != null
                    ? Image.network(_imageUrl!)
                    : Text("Enter a prompt to generate an image"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> generateImage(String prompt) async {
  const String apiKey ='{OPEN AI API KEY HERE}';
  const String apiUrl = 'https://api.openai.com/v1/images/generations';

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "prompt": prompt,
        "n": 1,
        "size": "1024x1024"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['url']; // Returns image URL
    } else {
      throw Exception('Failed to generate image');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}
