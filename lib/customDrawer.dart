import 'package:flutter/material.dart';
import 'dashboard_page.dart'; // DashboardPage widget'ını tanımladığınız dosya
import "chatbot.dart";
import "homepage.dart";
class customDrawer extends StatefulWidget {
  const customDrawer({super.key});

  @override
  State<customDrawer> createState() => _customDrawerState();
}

class _customDrawerState extends State<customDrawer> {
  @override
  Widget build(BuildContext context) {
    return 
    Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Ana Sayfa'),
            subtitle: Text('Geçmiş Sohbetler, Dokümanlar'),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );},
          ),
          ListTile(
            leading: Icon(Icons.assistant_navigation),
            title: Text("Fa'aI"),
            subtitle: Text("AI Destek Asistanı"),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatbotScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}



