import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_openai/dart_openai.dart';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      String userMessage = _controller.text.trim();
      _controller.clear();

      setState(() {
        _messages.insert(0, Message(text: userMessage, isUser: true));
      });

      _scrollToBottom();

       String aiResponse = await getChatGPTResponse(userMessage);
        debugPrint(aiResponse);
      setState(() {
        _messages.insert(0, Message(text: aiResponse, isUser: false));
      });

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OpenAI's ChatGPT API")),
      body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return Align(
                      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: message.isUser ? Colors.blueAccent : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: message.isUser ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "Enter message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
      )
    );
  }
}

class Message {
  final String text;
  final bool isUser;

  Message({required this.text, required this.isUser});
}


Future<String> getChatGPTResponse(String prompt) async {
  const String apiUrl = 'https://api.openai.com/v1/chat/completions';
  const String apiKey = '{API KEY HERE}';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      "model": "gpt-4",
      "messages": [
        {"role": "system", "content": "You are a helpful AI assistant."},
        {"role": "user", "content": prompt}
      ],
      "temperature": 0.7
    }),
  );

  if (response.statusCode == 200) {

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  } else {
    print("Error: ${response.body}"); // Debugging response
    throw Exception('Failed to fetch response: ${response.statusCode}');
  }
}
