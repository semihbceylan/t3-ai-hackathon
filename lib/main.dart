import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'homepage.dart'; // HomePage widget'ınızı tanımladığınız dosya
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard App',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return LoginScreen(); // Kullanıcı oturum açmamışsa giriş ekranı göster
          } else {
            return HomePage(); // Kullanıcı oturum açmışsa anasayfa göster
          }
        } else {
          return Center(child: CircularProgressIndicator()); // Yüklenme durumu
        }
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Bu yöntem, zaten kimliği doğrulanmış kullanıcılar için sessiz oturum açmayı dener
  Future<User?> _signInSilently() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        setState(() {}); // Widget'ı yeniden çiz, böylece kullanıcı durumu güncellenir
        return userCredential.user;
      }
      return null;
    } catch (e) {
      print('Sessiz oturum açma hatası: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hoşgeldiniz',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                User? user = await _signInSilently(); // Sessiz oturum açmayı dene
                if (user != null) {
                  print('Giriş başarılı: ${user.displayName}');
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              },
              child: Text('Google ile Giriş Yap (Silent)'),
            ),
            SizedBox(height: 20),
            GoogleSignInButton(), // Manuel Google giriş butonu
          ],
        ),
      ),
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          final GoogleSignInAccount? account = await googleSignIn.signIn();
          if (account != null) {
            print('Google ile giriş yapıldı: ${account.displayName}');
            final GoogleSignInAuthentication googleAuth = await account.authentication;

            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );

            final UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          }
        } catch (e) {
          if (e.toString().contains("popup_closed")) {
            print("Google giriş penceresi kapatıldı.");
          } else {
            print('Google ile oturum açma hatası: $e');
          }
        }
      },
      child: Text('Google ile Giriş Yap (Manual)'),
    );
  }
}
