# FINTECH ELITE - Premium Mobil Bankacılık ve Yatırım Uygulaması

Fintech Elite, Flutter kullanılarak geliştirilmiş, yüksek görselliğe, gelişmiş mikro animasyonlara ve üst düzey kullanıcı deneyimine (UX) sahip premium bir mobil bankacılık, varlık yönetimi ve yatırım terminali uygulamasıdır. Proje, modern finansal arayüz trendleri, neon detaylar, cammorfik (glassmorphic) bileşenler ve kesintisiz ekran geçişleri temel alınarak inşa edilmiştir.

---

## Proje Mimarisi ve Klasör Yapısı

Uygulama, ölçeklenebilirliği ve sürdürülebilirliği artırmak amacıyla **Feature-Based (Özellik Tabanlı)** klasör yapısı kullanılarak tasarlanmıştır. Çekirdek stil tanımlamaları (`core/theme`) tek bir noktada toplanırken, her bir işlevsel modül kendi içinde izole edilmiştir:

```text
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart         # HSL tabanlı premium koyu tema renk paleti
│       └── app_text_styles.dart     # Tipografi ve yazı stilleri
├── features/
│   ├── assets/
│   │   └── asset_detail_screen.dart # Varlık detay, etkileşimli grafik ve bento veriler
│   ├── auth/
│   │   ├── forgot_password_screen.dart  # Şifre yenileme e-posta giriş ekranı
│   │   ├── login_screen.dart            # Giriş ekranı (Absolute floating etiketler)
│   │   ├── otp_verification_screen.dart # 6 haneli gelişmiş OTP doğrulama ekranı
│   │   └── reset_password_screen.dart   # Şifre gücü analizörlü yeni şifre ekranı
│   ├── cards/
│   │   └── card_details_screen.dart     # 3D Tilt ve yüzen kart ayarları ekranı
│   ├── dashboard/
│   │   ├── dashboard_screen.dart        # Ana şablon ve bulanık yüzen alt menü
│   │   └── tabs/
│   │       ├── assets_tab.dart          # Varlıklarım sekmesi (index 2)
│   │       ├── home_tab.dart            # Dashboard ana sayfası (index 0)
│   │       ├── profile_tab.dart         # Profil bilgileri ve KYC düzenleme (index 3)
│   │       └── swap_tab.dart            # Gelişmiş yatırım ve trade sekmesi (index 1)
│   ├── notifications/
│   │   └── notifications_screen.dart    # Bildirim merkezi ve kategori filtreleme
│   └── transfers/
│       └── transfer_screen.dart         # Özel sanal klavyeli para transfer ekranı
└── main.dart                            # Uygulama başlangıç noktası (Splash entegrasyonlu)
```

---

## Öne Çıkan Özellikler ve Ekran Akışları

### 1. Giriş ve Güvenlik Akışı (Authentication & Security)
* **Splash Screen (`splash_screen.dart`):** Uygulama açılışında arka planda yavaşça büyüyen ve opaklaşan dairesel neon parıltı efekti (`_GlowEffect`) ile başlar. Cubic-bezier eğrisiyle gecikmeli olarak kayan logoların ardından, custom-drawn parlak yükleme barı çalışır ve pürüzsüz bir `FadeTransition` ile giriş ekranına aktarır.
* **Giriş Ekranı (`login_screen.dart`):** Şık input kutuları ve şifre gizle/göster kontrolleri barındırır.
* **OTP Doğrulama (`otp_verification_screen.dart`):** Şifremi unuttum akışında yer alan 6 haneli OTP doğrulama ekranıdır. Kutular arası otomatik odaklanma (forward/backward focus), panodan kopyalanan kodu doğrudan yapıştırma dinleyicisi (clipboard listener), neon lime odaklanma çerçeveleri ve 30 saniyelik "Resend" zamanlayıcısı içerir.
* **Yeni Şifre Oluşturma (`reset_password_screen.dart`):** Şifrenin karmaşıklığını (Weak, Fair, Good, Strong) harf, sayı ve özel karakter testleriyle gerçek zamanlı analiz eden 4 aşamalı dinamik şifre gücü göstergesi sunar.

### 2. Dashboard ve Modüler Tab Sistemi
* **Dashboard Shell (`dashboard_screen.dart`):** Uygulamanın ana iskeletidir. Arkası bulanıklaştırılmış (backdrop filter) premium yüzen Bottom Navigation Bar'ı barındırır ve sekmeler arası pürüzsüz geçişleri yönetir.
* **Home Sekmesi (`home_tab.dart`):**
  * Kademeli giriş (Staggered Entrance) animasyonları.
  * Halka parıltılı ve 45 derece çizgili tekrarlayan desene sahip interaktif iki adet banka kartı (Debit/Credit).
  * Hızlı eylemler ("Send", "Receive", "Swap", "More"). "Send" butonu doğrudan gelişmiş transfer ekranına bağlanmıştır.
* **Yatırım ve Trade Terminali (`swap_tab.dart`):**
  * Portföy değerini `$0.00`'dan başlayarak `$2,459,103.88` değerine doğru simüle eden 2 saniyelik animasyonlu sayaç.
  * Touch olayını (parmak hareketini) takip eden dikey kesikli kılavuz çizgisi (scrubber) ve o andaki değeri yansıtan dinamik veri kutucuğu içeren custom-drawn Bezier grafik arayüzü.
  * Hızlı alım/satım (BUY/SELL) emir paneli ve işlem günlüğü.
* **Varlıklar ve Wealth Sekmesi (`assets_tab.dart`):** Toplam zenginlik dağılımı, zaman aralığı butonları, custom bezier çizgi grafiği ve Crypto/Stocks/Cash detaylı bento kart listesi.
* **Profil ve KYC Düzenleme (`profile_tab.dart`):** Absolute konumlandırılmış input etiketleri, telefon numarası için özelleştirilmiş ülke kod kutusu ve profil fotoğraf güncelleme yapısı.

### 3. Derinlemesine Etkileşim ve Donanım Entegrasyonları
* **3D Tilt Kart Ayarları (`card_details_screen.dart`):**
  * Kart bileşeni sürekli süzülme fiziği (sinusoidal float animation) ile havada yüzer.
  * Kart üzerine basılı tutulup parmak kaydırıldığında, parmağın pozisyonuna göre 3 boyutlu eğilme (3D Tilt Transform) efekti gerçekleşir.
  * Kart ayarları bento kutularındaki switch'ler özel animasyonlu toggle widget'ları ile değiştirilmiştir.
  * Aylık limit ayarı neon lime gölgeli ilerleme gösteren bir slider ile yönetilir.
* **Özel Klavyeli Para Transferi (`transfer_screen.dart`):**
  * Sistem klavyesinden bağımsız, haptik geri bildirimli 3x4 özel sayısal sanal klavye tasarlanmıştır.
  * Tutar girildikçe miktar göstergesi ölçeklenme (scale) animasyonuyla tepki verir.
  * "Confirm Transfer" tıklandığında buton yükleme moduna geçer ve işlem tamamlandığında `heavyImpact` haptik titreşimi ile buton neon yeşile bürünüp içinde checkmark animasyonu oynatılırken, butondan dışarıya doğru ekranı kaplayan devasa bir radial dalga (Ripple Effect) yayılır.
* **Bildirim Merkezi (`notifications_screen.dart`):** "All Activity", "Security", "Transactions" ve "Promotions" kategorilerine göre filtreleme imkanı, okunmamış bildirimler için sol kenarda dikey renkli şeritler ve tümünü temizleme aksiyonu.

---

## Tasarım ve Animasyon Prensipleri

* **Renk Paleti:** Arka planlarda mutlak siyah (`#000000`) ve çok koyu gri tonları (`#0C0C0C`, `#131313`) tercih edilirken, birincil vurgu rengi olarak yüksek kontrastlı neon lime yeşili (`#C3F400` / `#D8FF00`) kullanılmıştır.
* **Backdrop Blur:** Cam paneller ve alt aksiyon barlarında `BackdropFilter` kullanılarak arkadaki içeriği buzlu gösteren premium cammorfik görünüm sağlanmıştır.
* **Haptik Geri Bildirimler:** Buton tıklamalarında `lightImpact`, limit güncellemelerinde `selectionClick` ve kritik onay anlarında `heavyImpact` fiziksel titreşimleri kullanılarak fiziksel dünya ile etkileşim hissiyatı güçlendirilmiştir.
* **Custom Painters:** Grafik eğrileri ve logolar, SVG kütüphanelerine bağımlılığı azaltmak ve performansı en üst seviyeye taşımak amacıyla tamamen Flutter'ın `CustomPainter` API'si ile sıfırdan çizilmiştir.

---

## Kurulum ve Çalıştırma

### Gereksinimler
* Flutter SDK (>= 3.0.0)
* Android Studio veya VS Code (Dart & Flutter eklentileri yüklü)
* Android Emulator (Önerilen: RAM >= 4GB, Page Size 16KB desteği için `VM heap size >= 512MB` ayarlanmış imaj) veya fiziksel cihaz.

### Adımlar
1. Depoyu yerel makinenize klonlayın.
2. Proje dizininde bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
3. Uygulamayı debug modunda başlatın:
   ```bash
   flutter run
   ```

