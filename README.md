*Bu proje TEKNOFEST 2024 Antalya T3AI Hackathon Yarışması Uygulama Geliştirme Kategorisi için geliştirilmiştir.*

Fa'aI
Eğitimde Eşitlik: Yapay Zeka Destekli Cross-Platform Uygulama
Proje Adı: FineITUne
Geliştirici: fineITUne Takımı
Platformlar: Flutter, Python, Firebase

Proje Hakkında
Bu proje, eğitimde fırsat eşitliğini sağlamak amacıyla geliştirilmiş, yapay zeka destekli bir mobil ve web uygulamasıdır. Uygulama, bireylerin öğrenme süreçlerini daha etkili ve verimli hale getirerek kişiselleştirilmiş bir eğitim deneyimi sunmayı hedefler.

Özellikler
Yapay Zeka Destekli Eğitim Yardımcısı: Kullanıcıların sorularını analiz ederek yapay zeka destekli öğrenme asistanı sağlar.
Kişiselleştirilmiş Eğitim İçeriği: Kullanıcıların öğrenme eksikliklerini analiz eder ve ihtiyaca göre kişiselleştirilmiş öneriler sunar.
Çapraz Platform Desteği: Hem mobil hem de web üzerinde çalışabilir. (Flutter kullanılarak geliştirildi.)
Gerçek Zamanlı Veri Senkronizasyonu: Firebase tabanlı veritabanı ile kullanıcı ilerlemeleri ve geri bildirimleri gerçek zamanlı olarak kaydedilir.
Eğitim Materyali Yönetimi: Kullanıcıların konu başlıklarına göre kendi çalışma materyallerini seçmelerine olanak sağlar.
Teknolojiler
Flutter: Çapraz platform uygulama geliştirme için kullanıldı.
Python (Flask): Backend servisleri ve yapay zeka ile entegrasyon.
Firebase: Gerçek zamanlı veri tabanı ve kullanıcı doğrulama işlemleri.
Firestore: Kullanıcı verilerinin ve konuşma geçmişlerinin depolanması.
````

````

## fineITUne: 563609
- Furkan Nevzat Gürüz
- Semih Bahadır Ceylan
- Kerem Bükücü

## Uygulamadan Ekran Görüntüleri
![Ekran görüntüsü 2024-09-07 110352](https://github.com/user-attachments/assets/ef33a69e-86d8-434d-b68b-e098f9a997b2)
![Ekran görüntüsü 2024-09-07 110532](https://github.com/user-attachments/assets/be19bf65-0ac9-4fc3-a1b0-b71b17e6a24a)
![Ekran görüntüsü 2024-09-07 110603](https://github.com/user-attachments/assets/b19d3864-0850-41dc-8385-6792aeb92c10)
![Ekran görüntüsü 2024-09-07 110639](https://github.com/user-attachments/assets/1a62a3cf-036f-4fef-b238-1303d03f0d18)

##Uygulamayı çalıştırmak için öncelikle lib/kerem.py dosyasını çalıştırmanız, akabinde yeni bir termimal açıp "flutter run" komutunu terminale yazıp 2 "(web)" seçmeniz gerekmektedir. Uygulama açıldığında Google ile giriş yapmanız gerekeceğinden yetkilendirme sorunu yaşarsanız iletişime geçmekten çekinmeyin. 

##Programın bu versiyonunda Dil modeliyle geliştirdiğimiz birçok fonksiyonu Flutter Arayüzü'nde aktif edemedik. Bazı fonksiyonlarımızı içeren Flutter uygulamasında Chatbot ile konuşma aktif. Eğer diğer fonksiyonlarımızı görmek isterseniz "main.py" dosyasını komut satırında çalıştırabilirsiniz. 
Chatbot ile konuşurken, soru hazırlamasını, sınav hazırlamasını veya program hazırlamasını ifade edebilecek bir şey söylediğinizde bunu dinamik bir şekilde anlayıp ajan gibi aksiyon alacak. Onun harici eğer daha önce rag istemine yüklemiş olduğunuz bir kitap hakkında

## Uygulamayı Lokalde Çalıştırma
Uygulamanın Lokalde Çalıştırılması
Gerekli Bağımlılıklar
Uygulamayı yerel olarak çalıştırmak için aşağıdaki yazılımların bilgisayarınızda yüklü olduğundan emin olun:

Flutter (mobil ve web uygulaması için)
Python (backend ve yapay zeka servisleri için)
Firebase CLI (Firebase ile entegrasyon için)
Adım Adım Kurulum
1. Depoyu Klonlayın
Proje dosyalarını bilgisayarınıza indirin:

bash
Kodu kopyala
git clone https://github.com/kullanici-adi/proje-ismi.git
cd proje-ismi
2. Flutter Bağımlılıklarını Yükleyin
Flutter projesi için gerekli paketleri yüklemek için şu komutu çalıştırın:

bash
Kodu kopyala
flutter pub get
3. Python Bağımlılıklarını Yükleyin
Backend servisi için gerekli Python paketlerini yükleyin:

bash
Kodu kopyala
pip install -r backend/requirements.txt
4. Firebase Projesini Yapılandırın
Firebase ile entegrasyon yapmak için Firebase Console üzerinden bir proje oluşturun ve google-services.json dosyasını Flutter projesinin android/app/ klasörüne ekleyin. Ayrıca Firebase Authentication ve Firestore yapılandırmalarınızı yapın.



npm install -g firebase-tools
firebase login
Firebase'e bağlantıyı doğrulamak için:


firebase init
5. Flutter Uygulamasını Çalıştırın
Flutter projesini tarayıcıda çalıştırmak için şu komutu kullanın:


flutter run -d chrome
Eğer mobil cihazda test etmek isterseniz, cihazınızı bağlayıp aşağıdaki komutu kullanabilirsiniz:


flutter run
6. Flask Backend'ini Çalıştırın
Backend (Flask API) servisini çalıştırmak için terminalde şu komutu çalıştırın:

cd backend
flask run
Bu komut, Flask sunucusunu yerel olarak http://127.0.0.1:5000/ adresinde başlatacaktır.

7. Uygulama Bağlantısı
Flutter frontend'i ile Flask backend'i arasındaki bağlantıyı sağlamak için, Flutter projesinde yer alan api_endpoint değişkenini backend sunucusunun URL'si ile güncelleyin:


const apiEndpoint = "http://127.0.0.1:5000/";
8. Firebase Hizmetlerini Kullanma
Firebase entegrasyonu için gerekli ayarları yaptıktan sonra, uygulamanın Firebase ile tam uyumlu çalıştığından emin olmak için aşağıdaki komutları çalıştırabilirsiniz:


firebase emulators:start
Bu komut, yerel olarak Firebase hizmetlerini taklit edecek ve test yapmanıza olanak tanıyacaktır.

Sorun Giderme
Flutter paketleri yüklenmezse: Flutter SDK'nın doğru kurulu olduğundan ve flutter doctor komutunu kullanarak ortamınızın düzgün ayarlandığından emin olun.
Flask sunucusu çalışmıyorsa: Python ortamınızı ve gerekli kütüphanelerin doğru yüklendiğini kontrol edin (pip install -r requirements.txt).



