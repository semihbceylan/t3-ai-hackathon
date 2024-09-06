import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // FocusNode tanımlıyoruz
  final List<Map<String, String>> _messages = [];
  String _typingMessage = ""; // Mesaj animasyonu sırasında gösterilecek geçici mesaj

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      _controller.clear();

      _addUserMessage(userMessage);

      // Bot cevabını API'ye gönderelim ve cevabı alalım
      final botResponse = await _fetchChatbotResponse(userMessage);

      // Bot cevabını animasyonlu bir şekilde ekleyelim
      _addBotMessage(botResponse);

      // Mesaj gönderildikten sonra metin kutusunu tekrar odaklıyoruz
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  Future<String> _fetchChatbotResponse(String message) async {
    const apiUrl = 'http://your-server-ip:5000/chatbot'; // Python API adresi

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response']; // API'den gelen yanıt
      } else {
        return 'Chatbot ile bağlantı kurulamadı.';
      }
    } catch (error) {
      return 'Bir hata oluştu: $error';
    }
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({"user": message});
    });
  }

  void _addBotMessage(String message) {
    _typingMessage = ""; // Başlangıçta bot mesajı boş
    int currentIndex = 0;

    // Her karakteri sırayla eklemek için Timer kullanıyoruz
    Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (currentIndex < message.length) {
        setState(() {
          _typingMessage += message[currentIndex];
        });
        currentIndex++;
      } else {
        // Mesaj tamamlandığında mesajlar listesine ekliyoruz
        setState(() {
          _messages.add({"bot": _typingMessage});
          _typingMessage = ""; // Geçici mesajı sıfırlıyoruz
        });
        timer.cancel(); // Zamanlayıcıyı durduruyoruz
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Chatbot', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(icon: Icon(Icons.search, color: Colors.black), onPressed: () {}),
          PopupMenuButton<int>(
            icon: Icon(Icons.notifications, color: Colors.black),
            onSelected: (value) {
              if (value == 1) {
                print("Bildirimler");
              } else if (value == 2) {
                print("Hoş Geldiniz");
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.notification_important_rounded),
                  title: Text('Merhaba!'),
                  subtitle: Text('Yeni bildirimleriniz var.'),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.notifications_active_rounded),
                  title: Text('Hoş Geldiniz!'),
                  subtitle: Text('Uygulamada yeni özellikler mevcut.'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: _messages.length + (_typingMessage.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          // Typing Effect için geçici mesaj
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _typingMessage,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        } else {
                          final message = _messages[index];
                          final isUser = message.containsKey("user");
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              margin: EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isUser ? Colors.blue[200] : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isUser ? message["user"]! : message["bot"]!,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.attach_file),
                          onPressed: () {
                            print("Ataç ikonu tıklandı.");
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode, // FocusNode'u TextField'a bağlıyoruz
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              _sendMessage();
                            },
                            decoration: InputDecoration(
                              hintText: "Mesajınızı yazın...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}