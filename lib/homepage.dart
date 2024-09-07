import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth paketi
import 'main.dart'; // LoginScreen'i ekleyin
import 'dashboard_page.dart'; // DashboardPage widget'ını tanımladığınız dosya
import "chatbot.dart";
import "customDrawer.dart";

class HomePage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser; // Kullanıcı bilgilerini alıyoruz

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF5F5F5),
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "Fa'aI Eğitim Destek Platformu",
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
        PopupMenuButton<int>(
          tooltip: null,
          icon: Icon(Icons.notifications, color: Colors.black),
          offset: Offset(0, 50), // Menü biraz daha aşağıda açılacak
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
                title: Text('Merhaba !'),
                subtitle: Text('Yeni bildirimleriniz var.'),
              ),
            ),
            PopupMenuItem<int>(
              value: 2,
              child: ListTile(
                leading: Icon(Icons.notifications_active_rounded),
                title: Text('Hoş Geldiniz !'),
                subtitle: Text('Uygulamada yeni özellikler mevcut.'),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: Text(
              user != null ? user!.displayName ?? 'User' : 'Guest',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              _showProfileDialog(context);
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: user != null && user!.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user!.photoURL == null
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ],
    ),
    drawer: customDrawer(),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Row(
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildGraphCard(),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildNewsCard(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  // Profil popup'ını gösteren fonksiyon
  void _showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.all(16.0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user != null && user!.photoURL != null
                    ? NetworkImage(user!.photoURL!) // Kullanıcının profil resmi
                    : null,
                child: user!.photoURL == null
                    ? Icon(Icons.person, color: Colors.white, size: 40) // Profil resmi yoksa ikon
                    : null,
              ),
              SizedBox(height: 12),
              Text(
                user != null ? user!.displayName ?? 'User' : 'Guest', // Kullanıcının ismi
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Geliştirici', // Altına "Geliştirici" yazısı
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  // Ayarlar sayfası yönlendirme veya fonksiyon
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out'),
                onTap: () {
                  _signOut(context); // Çıkış fonksiyonunu çağır
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Sign-out işlemi ve yönlendirme fonksiyonu
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Firebase'den çıkış yap
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // LoginScreen'e yönlendir
    );
  }


  Widget _buildGraphCard() {
    List<Map<String, String>> conversations = [
      {'title': '11_sinif_biyoloji_test.pdf', 'time': '2 Saat Önce'},
      {'title': '08_09_24_ders_plani.pdf', 'time': '5 Saat Önce'},
      {'title': '11_sinif_turkce_konu.pdf', 'time': '3 Gün Önce'},
      {'title': '02_09_24_sohbet_kaydi.docx', 'time': '6 Gün Önce'},
    ];

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dokümanlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {},
                  leading: Icon(Icons.document_scanner, color: Colors.green),
                  title: Text(conversations[index]['title']!),
                  subtitle: Text(conversations[index]['time']!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

  Widget _buildNewsCard() {
    List<Map<String, String>> conversations = [
      {'title': '11.Sınıf Biyoloji Hücreler Konu Anlatımı', 'time': '2 Saat Önce'},
      {'title': '11.Sınıf Biyoloji Hücreler Test Hazırlama', 'time': '6 Saat Önce'},
      {'title': '11.Sınıf Coğrafya Soru-Cevap', 'time': '2 Gün Önce'},
      {'title': 'Ders Planı Hazırlama Görevi', 'time': '2 Gün Önce'},
      {'title': 'Türkçe Dil Bilgisi Yanlış Soru Çözümü', 'time': '3 Gün Önce'},
    ];

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Sohbetler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {},
                  leading: Icon(Icons.article, color: Colors.green),
                  title: Text(conversations[index]['title']!),
                  subtitle: Text(conversations[index]['time']!),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

