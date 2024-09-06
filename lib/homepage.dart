import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth paketi
import 'main.dart'; // LoginScreen'i ekleyin
import 'dashboard_page.dart'; // DashboardPage widget'ını tanımladığınız dosya
import "chatbot.dart";

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
        'Dashboard',
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
    drawer: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: Text(
              'C',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            subtitle: Text('Ana sayfaya dön'),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            subtitle: Text('Genel bakış ekranına git'),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.hotel),
            title: Text('Chat'),
            subtitle: Text('Genel bakış ekranına git'),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.contacts),
            title: Text('Contacts'),
            subtitle: Text('İletişim bilgilerini düzenle'),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {},
          ),
        ],
      ),
    ),
    body: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatButton('Total Sales', '1.000.000 \$', Icons.show_chart),
              _buildStatButton('Total Profit', '128.000 \$', Icons.money),
              _buildStatButton('Orders', '12346', Icons.shopping_cart),
              _buildStatButton('Customers', '3231', Icons.people),
            ],
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

  Widget _buildStatButton(String title, String value, IconData icon) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.zero,
      ),
      child: SizedBox(
        height: 70,
        width: 300,
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Icon(icon, color: Colors.green, size: 30),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Center(
                child: Text('Graph Placeholder'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Sohbetlerim',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {},
                  leading: Icon(Icons.article, color: Colors.green),
                  title: Text('Lorem ipsum dolor sit amet'),
                  subtitle: Text('5 minutes ago'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
