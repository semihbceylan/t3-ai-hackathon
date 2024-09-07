import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore için
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // Dosya seçmek için
import 'package:path_provider/path_provider.dart'; // Geçici dizinlere erişim için
import 'package:path/path.dart' as path; // Dosya uzantısı ve adı işlemleri için

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
  String? _sessionId; // Kaydedilen oturumun ID'si (güncelleme için gerekli)
  File? _selectedFile; // Seçilen dosya

  // Dosya seçme ve Python API'ye gönderme fonksiyonu
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'docx'], // Sadece belirli uzantılar
    );

    if (result != null) {
      // Seçilen dosya
      File file = File(result.files.single.path!);

      setState(() {
        _selectedFile = file; // Seçilen dosya state'de saklanıyor
      });

      // Dosyayı Python API'ye yükleme
      await _uploadFileToPythonAPI(file);
    } else {
      print("Dosya seçilmedi.");
    }
  }

  // Dosya türüne göre icon döndüren fonksiyon
  Icon _getFileIcon(String extension) {
    switch (extension) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'docx':
        return Icon(Icons.description, color: Colors.blue);
      case 'txt':
        return Icon(Icons.text_snippet, color: Colors.green);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.grey);
    }
  }

  // Dosyayı Python API'ye gönderme fonksiyonu
  Future<void> _uploadFileToPythonAPI(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:5000/upload_file'));

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Dosya başarıyla yüklendi.");
        _addBotMessage("Dosya başarıyla yüklendi.");
      } else {
        print("Dosya yükleme hatası: ${response.statusCode}");
        _addBotMessage("Dosya yükleme hatası.");
      }
    } catch (e) {
      print("API'ye dosya yükleme hatası: $e");
      _addBotMessage("API'ye dosya yüklenemedi.");
    }
  }

  // Geri bildirimi kaydetme fonksiyonu
  Future<void> _saveDislikeFeedback(String botMessage, String feedback) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final List<Map<String, String>> chatData = _messages;
      await FirebaseFirestore.instance.collection('feedback').add({
        'user_id': user.uid,
        'messages': chatData,
        'user_feedback': feedback,
        'timestamp': FieldValue.serverTimestamp(),

      });
      print("Geri bildirim kaydedildi.");
      _addBotMessage("Geri bildiriminiz için teşekkürler.");
    }
  }


  // Sohbeti Firebase'e kaydetme fonksiyonu
  Future<void> _saveChatSession() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _messages.isNotEmpty) {
      final List<Map<String, String>> chatData = _messages;

      if (_sessionId == null) {
        DocumentReference docRef = await FirebaseFirestore.instance.collection('conversations').add({
          'user_id': user.uid,
          'messages': chatData,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _sessionId = docRef.id;
      } else {
        await FirebaseFirestore.instance.collection('conversations').doc(_sessionId).update({
          'user_id': user.uid,
          'messages': chatData,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      print("Sohbet kaydedildi.");
    }
  }

  // Mesaj gönderme ve API'den yanıt alma fonksiyonu
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

  // Yeni: Yanıtların altına buton ekleme
  Widget _buildMessageWithActions(Map<String, String> message, Animation<double> animation) {
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
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
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
            if (!isUser) // Bot mesajıysa butonları göster
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: Colors.green),
                    onPressed: () {
                      _addBotMessage("Beğendiniz! Teşekkürler.");
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.thumb_down, color: Colors.red),
                    onPressed: () {
                      _showDislikeFeedbackDialog(message["bot"]!);
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Dislike durumunda geri bildirim penceresini gösteren fonksiyon
  void _showDislikeFeedbackDialog(String botMessage) {
    final TextEditingController _feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Geri Bildirim"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Bu mesajla ilgili geri bildiriminizi yazın:"),
              SizedBox(height: 10),
              Text(
                "\"$botMessage\"",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Geri bildirim",
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                String feedback = _feedbackController.text;
                if (feedback.isNotEmpty) {
                  _saveDislikeFeedback(botMessage, feedback);
                  Navigator.of(context).pop();
                }
              },
              child: Text("Gönder"),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Fa'aI Eğitim Destek Asistanı", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.black),
            onPressed: _saveChatSession, // Save butonu tıklandığında sohbet kaydedilecek
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
                  if (_selectedFile != null)
                    ListTile(
                      leading: _getFileIcon(path.extension(_selectedFile!.path).replaceAll('.', '')),
                      title: Text(path.basename(_selectedFile!.path)),
                      subtitle: Text("Dosya türü: ${path.extension(_selectedFile!.path).replaceAll('.', '').toUpperCase()}"),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedFile = null; // Dosya önizlemesi siliniyor
                          });
                        },
                      ),
                    ),
                  Expanded(
                    child: AnimatedList(
                      key: _listKey,
                      padding: EdgeInsets.all(16.0),
                      initialItemCount: _messages.length,
                      itemBuilder: (context, index, animation) {
                        return _buildMessageWithActions(_messages[index], animation);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.attach_file, color: Colors.black),
                          onPressed: _pickFile, // Ataç butonu tıklandığında dosya seçilecek
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
