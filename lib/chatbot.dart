import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode(); 
  final List<Map<String, String>> _messages = [];
  String _typingMessage = ""; 

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Mesaj göndermeden önce API'ye bağlanma ve yanıt alma fonksiyonu
  Future<void> _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text;
      _controller.clear();

      _addUserMessage(userMessage);

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:5000/chat'), 
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user_input': userMessage}),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final botResponse = jsonResponse['response'];

          _addBotMessage(botResponse);
        } else {
          _addBotMessage("Hata: API'den geçerli bir yanıt alınamadı.");
        }
      } catch (e) {
        _addBotMessage("Hata: API'ye bağlanılamadı. Lütfen daha sonra tekrar deneyin.");
      }

      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  // Kullanıcı mesajını ekleme fonksiyonu
  void _addUserMessage(String message) {
    setState(() {
      _messages.add({"user": message});
    });
    _listKey.currentState!.insertItem(_messages.length - 1);
  }

  // Bot mesajını ekleme ve animasyonlu yazma efekti
  void _addBotMessage(String message) {
    _typingMessage = ""; 
    int currentIndex = 0;

    Timer.periodic(Duration(milliseconds: 20), (timer) {
      if (currentIndex < message.length) {
        setState(() {
          _typingMessage += message[currentIndex];
        });
        currentIndex++;
      } else {
        setState(() {
          _messages.add({"bot": _typingMessage});
          _typingMessage = ""; 
        });
        _listKey.currentState!.insertItem(_messages.length - 1);
        timer.cancel(); 
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
                    child: AnimatedList(
                      key: _listKey,
                      padding: EdgeInsets.all(16.0),
                      initialItemCount: _messages.length,
                      itemBuilder: (context, index, animation) {
                        final message = _messages[index];
                        final isUser = message.containsKey("user");
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: isUser ? Offset(1, 0) : Offset(-1, 0),
                            end: Offset(0, 0),
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.fastOutSlowIn,
                          )),
                          child: Align(
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
                          ),
                        );
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
                            focusNode: _focusNode, 
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
