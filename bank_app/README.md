<h1 align="center">⚡ FINTECH ELITE ⚡</h1>
<p align="center">
  <b>Next-Generation Mobil Wealth &amp; Yatırım Terminali</b><br>
  <i>Flutter ile sıfırdan inşa edilmiş, kurumsal düzeyde (institutional-grade) yüksek sadakatli finans terminali.</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter Badge">
  <img src="https://img.shields.io/badge/Dart-2.17+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart Badge">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge&logo=android" alt="Platforms Badge">
</p>

---

## 🛠 TEKNİK ÖZELLİKLER TABLOSU

```text
┌────────────────────────────────────────────────────────┐
│  MİMARİ YAPISI : Feature-Based Modular (Özellik Bazlı) │
│  TASARIM DİLİ  : Prestige Dark & Neo-Lime Accent (HSL) │
│  GRAFİK MOTORU : Özel CustomPaint Bezier Matematik     │
│  DONANIM ENTEG.: Fiziksel Haptik Geri Bildirim Sistemi │
│  AKICILIK      : Custom PageRoute & Kademeli Girişler  │
└────────────────────────────────────────────────────────┘
```

---

## 🏗 DETAYLI PROJE KLASÖR YAPISI

Projenin sürdürülebilir olması adına, tüm bileşenler, ekranlar ve iş mantığı özellik gruplarına göre izole edilmiştir.

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

## 💎 ULTRA HIGH-FIDELITY BİLEŞENLER VE EKRAN DETAYLARI

Uygulamanın her pikseli ve geçişi, en üst segment finansal mobil uygulamaların arayüzleri analiz edilerek tasarlanmıştır.

### 🌟 1. İnteraktif 3D Kart Kontrol Paneli (`CardDetailsScreen`)
* **3D Tilt Efekti:** Kullanıcı parmağını kart üzerinde hareket ettirdiğinde, dokunuş koordinatlarına göre kart 3 boyutlu olarak `Matrix4` transformasyonuyla eğilir. Parmak bırakıldığında pürüzsüzce eski konumuna döner.
* **Süzülme Fiziği:** Kart ekran üzerinde asılı duruyormuş gibi sürekli olarak yumuşak bir sinüzoidal süzülme animasyonu oynatır.
* **Mastercard Grid Çizimi:** Tamamen kod tabanlı `CustomPainter` ile çizilmiş 45 derece çizgili desenler ve üst üste binen transparan marka halkaları.
* **Akıllı Limit Slider:** İlerleme durumuna göre dinamik parıltı (neon glow) yayan ve sürükleme esnasında limit değerini milisaniyelik gecikme olmadan güncelleyen özelleştirilmiş `Slider`.

### ⚡ 2. Özel Keypad ve Prestige Ripple Transfer Akışı (`TransferScreen`)
* **Dahili Sanal Klavye:** İşletim sisteminin klavyesine ihtiyaç duymadan çalışan, her basışta hafif fiziksel geri bildirim (`lightImpact`) veren 3x4 özel sayısal tuş takımı.
* **Dinamik Ölçeklenme:** Girilen tutarın uzunluğuna ve basılan tuşa göre anlık esneme ve küçülüp büyüme (`ScaleTransition`) animasyonu.
* **Prestige Onay Animasyonu:** Transfer onaylandığında butonda dönen loader belirir, işlem tamamlandığında `heavyImpact` ile buton neon lime yeşiline boyanır, dairesel başarı checkmark'ı çizilir ve butondan dışarıya doğru tüm ekranı saniyeler içinde kaplayıp kaybolan devasa bir parıltılı halka dalgası (`Ripple Effect`) yayılır.

### 📊 3. Kusursuz Custom-Paint Bezier Grafikler (`SwapTab` & `AssetDetailScreen`)
* **Spline Interpolation:** Verilen veri noktalarını keskin köşeler olmadan pürüzsüz bezier eğrilerine dönüştüren gelişmiş `Path.cubicTo` hesaplamaları.
* **Dinamik Takipçi (Scrubber):** Grafiğe dokunulduğunda parmağın altındaki değeri okuyan kesikli dikey kılavuz çizgisi ve ekran sınırlarına çarpmadan hareket eden dinamik bilgi balonu (`Floating Tooltip`).
* **Degrade Dolgu:** Grafiğin altındaki alanı azalan opaklıkla dolduran lime neon gradyan maskesi.

### 🔒 4. Güvenlik ve Kimlik Doğrulama Akışları
* **Splash Screen (`splash_screen.dart`):** Radial yeşil parıltılı ambient backing ve kademeli yukarı kayarak belirme animasyonları.
* **OTP Ekranı (`otp_verification_screen.dart`):** Kutular arası otomatik geçiş, clipboard'dan 6 haneli kodu doğrudan yakalayıp doldurma yeteneği ve odaklanılan kutunun neon parlaması.
* **Şifre Gücü Analizörü (`reset_password_screen.dart`):** Şifrenin zorluğunu gerçek zamanlı doğrulayan 4 barlı dinamik güç göstergesi.

---

## 🎨 PREMİUM TASARIM DİLİ VE METRİKLERİ

> Projenin tüm görsel unsurları en üst düzey sadakat seviyesini korumak için tasarlanmıştır.

* **HSL Tabanlı Renk Sistemi:** Arka planlarda derin uzay siyahı (`#000000`) ve antrasit tonları tercih edilirken, vurgu alanlarında kurumsal neon yeşil (`#C3F400` / `#D8FF00`) kullanılarak maksimum kontrast ve okunabilirlik yakalanmıştır.
* **Buzlu Cam (Cammorfizm) Efekti:** Sayfa geçişleri ve alt aksiyon barlarında `BackdropFilter` ile arkadaki dinamik öğeleri buzlu gösteren premium katmanlar oluşturulmuştur.
* **Haptik Dokunsal Geri Bildirim:** Kullanıcı etkileşiminin her adımında (Slider kaydırmaları, tuş takımı basışları, işlem onayları) farklı şiddette haptik motor (`lightImpact`, `mediumImpact`, `heavyImpact`) tetiklemeleri yapılmıştır.

---

## 🚀 KURULUM VE ÇALIŞTIRMA TALİMATLARI

### Ön Gereksinimler
* Flutter SDK (sürüm `>= 3.0.0`)
* Dart SDK (sürüm `>= 2.17.0`)
* Android Emulator (Tavsiye edilen: Android 13+ AVD, Minimum RAM: `4096MB`, VM Heap Size: `512MB` bellek sınırlarından kaynaklı çökmeleri engellemek için) veya Fiziksel Test Cihazı.

### Çalıştırma Adımları

1. Proje bağımlılıklarını indirin:
   ```bash
   flutter pub get
   ```

2. Kod analizlerini kontrol edin ve herhangi bir hata/uyarı olmadığından emin olun:
   ```bash
   flutter analyze
   ```

3. Uygulamayı cihazınızda çalıştırın:
   ```bash
   flutter run
   ```
