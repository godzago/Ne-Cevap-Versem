<div align="center">

# 🤖 Ne Cevap Versem?

### *Zor Mesajlara AI Destekli Akıllı Cevap Üretici*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.x-4285F4?style=for-the-badge&logo=dart&logoColor=white)](https://riverpod.dev)
[![Groq](https://img.shields.io/badge/Groq_API-LLaMA_3-f55036?style=for-the-badge)](https://groq.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

> **"Ne diyeceğimi bilmiyorum."** dediğin anlara son.  
> Patronun, sevgilin, HR müdürü veya sinir bozucu bir akraban — hepsine doğru cevabı bul.

</div>

---

## 📋 İçindekiler

- [Proje Hakkında](#-proje-hakkında)
- [Case Study: Teknik Karar Süreci](#-case-study-teknik-karar-süreci)
- [Uygulama Modları](#-uygulama-modları-4-persona)
- [Mimari](#-mimari)
- [Teknoloji Yığını](#-teknoloji-yığını)
- [Kurulum](#-kurulum)
- [Güvenlik: API Key Yönetimi](#-güvenlik-api-key-yönetimi)
- [Özellikler & Yol Haritası](#-özellikler--yol-haritası)
- [Lisans](#-lisans)

---

## 🎯 Proje Hakkında

**Ne Cevap Versem?**, günlük hayatta alınan mesajlara nasıl cevap verileceğini bilemeyen kullanıcılara yönelik bir **Flutter tabanlı AI uygulamasıdır**. Kullanıcı, aldığı mesajı (metin veya ekran görüntüsü olarak) girer; uygulama 4 farklı tondan birini seçerek **3 farklı alternatif cevap** üretir.

Bu proje; **Micro-SaaS** modeliyle geliştirilmiş, reklam ve premium abonelik geliri hedefleyen ticari bir mobil üründür.

---

## 🧪 Case Study: Teknik Karar Süreci

> Bu bölüm, projenin teknik geliştirme sürecindeki kararları ve çözülen problemleri belgelemektedir.

### Problem Tanımı

Kullanıcı araştırmasında tespit edilen çekirdek sorun:
> *"Whatsapp/Slack'ten gelen mesaja nasıl cevap vereceğimi bilemiyorum."*

Bu sorun özellikle şu senaryolarda kritikleşiyor:
- İşyerinde patrondan gelen pasif-agresif mesajlar
- Romantik ilişkilerde yanlış anlaşılmalar
- İş görüşmelerinde tuzak sorular
- Aile baskısı veya sosyal medya trolleri

### Çözüm Yaklaşımı: 4-Persona AI Mimarisi

Tek bir "genel cevap üreteci" yerine, **bağlama özel 4 farklı persona** tasarlandı. Bu kararın arkasında şu veri var:

| Yaklaşım | Kullanıcı Memnuniyeti | Kapsam |
|---|---|---|
| Genel AI Asistan | Ortalama | Geniş ama sığ |
| **Bağlama Özel Persona (Bu Proje)** | **Yüksek** | **Dar ama derin** |

**Neden?** Kullanıcı "iyi bir cevap" istemez; **kendi sesine uyan** bir cevap ister.

---

### Problem 1: API Güvenliği — İstemci Tarafında Key Saklamak

**Sorun:** Flutter uygulaması doğrudan Groq/OpenAI API'sine istek atarsa, APK'nın tersine mühendislikle analiz edilmesi halinde API anahtarı çalınabilir.

**İlk (Yanlış) Yaklaşım:**
```dart
// ❌ YANLIŞ: API key doğrudan istemcide
final response = await http.post(
  Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
  headers: {'Authorization': 'Bearer $hardcodedKey'},
);
```

**Uygulanan Çözüm: `flutter_dotenv` + `.gitignore`**
```dart
// ✅ DOĞRU: Key .env dosyasında, .gitignore'da gizli
await dotenv.load(fileName: ".env");
final apiKey = dotenv.env['GROQ_API_KEY']!;
```

**Üretim için Doğru Çözüm (Yol Haritasında):**
- Firebase Cloud Functions üzerinden bir proxy katmanı kurulacak
- İstemci, API key'i hiç görmeyecek; sadece Firebase'e istek atacak

---

### Problem 2: State Yönetimi — Birden Fazla Asenkron State

**Sorun:** Kullanıcı bir cevap istediğinde, UI'ın şu durumları takip etmesi gerekiyor:
- `isLoading` → Spinner göster
- `responses` → 3 cevap kartı göster  
- `error` → Hata mesajı göster
- `remainingCredits` → Ücretsiz hak sayacı

**Karar: Riverpod ile `AsyncValue` Kombinasyonu**

```dart
// State modeli — tek bir sealed class ile tüm durumlar
final chatProvider = StateNotifierProvider<ChatNotifier, AsyncValue<ChatState>>(
  (ref) => ChatNotifier(ref),
);
```

Riverpod seçildi çünkü:
1. `Provider` → Bağımlılık enjeksiyonu
2. `StateNotifier` → Kompleks state mutasyonları
3. `AsyncValue` → Loading/Error/Data state'lerini tip güvenli yönetim

---

### Problem 3: Monetizasyon — Freemium Sınırı Nasıl Uygulanır?

**Karar: Günlük 3 Ücretsiz İstek**

```
Kullanıcı İsteği
      ↓
[Local Storage Kontrolü]
  ├── Kredi Var → AI'ya İlet → Cevap Göster → Kredi -1
  └── Kredi Yok → [Tarih Kontrolü]
              ├── Yeni Gün → Krediyi 3'e Sıfırla
              └── Aynı Gün → Paywall Göster (Premium)
```

**Kilitli Özellikler (Premium):**
- Patron & Mülakat modları (yüksek değer, kurumsal hedef kitle)
- Görsel/ekran görüntüsü yükleme (OCR)
- Günde 3'ten fazla sorgu

---

### Problem 4: Görsel Input — Ekran Görüntüsü Nasıl İşlenir?

**Zorluk:** Kullanıcı WhatsApp/Slack ekranını paylaşmak istiyor ama metin tanıma (OCR) gerekiyor.

**Çözüm Akışı:**
```
Kullanıcı Görsel Seçer (image_picker)
      ↓
Backend Proxy'e Base64 Gönderilir
      ↓
Groq Vision / Gemini Vision → Metin Çıkarılır
      ↓
Çıkarılan Metin → Persona Prompt'una Eklenir
      ↓
3 Alternatif Cevap Döner
```

---

## 🎭 Uygulama Modları (4 Persona)

| Mod | Hedef Kitle | Ton | Örnek Senaryo |
|---|---|---|---|
| 👔 **Patron / Yönetici** | Çalışanlar, freelancerlar | Profesyonel, sınır koyucu | "Cumartesi çalışabilir misin?" |
| 💕 **Sevgili / Flört** | Romantik ilişkiler | Empatik, net | Pasif-agresif partner mesajları |
| 😏 **Pasif-Agresif** | Toksik sosyal çevre | Zekice, sivri | Akraba/sosyal medya trolleri |
| 🎯 **Mülakat (HR)** | İş arayanlar | Özgüvenli, yapılandırılmış | "Zayıf yönleriniz neler?" |

Her mod için 3 farklı cevap tonu üretilir:
- 🟢 **Politik & Kibar** — Güvenli, diplomatik
- 🟡 **Net & Kısa** — Doğrudan, minimal
- 🔴 **Yaratıcı / Esprili** — Akıllı, özgün

---

## 🏗️ Mimari

```
lib/
├── core/
│   ├── constants/          # API endpoint'leri, mod ID'leri
│   ├── services/           # HTTP, local storage, analytics
│   └── utils/              # Tarih yardımcıları, validasyon
├── data/
│   ├── models/             # ChatRequest, ChatResponse, UserCredit
│   └── repositories/       # AI API soyutlama katmanı
├── viewmodels/
│   ├── chat_viewmodel.dart # Chat state & business logic
│   └── home_viewmodel.dart # Mod seçimi & kredi durumu
└── views/
    ├── home/               # 4-kart ana ekran
    ├── chat/               # Mesaj input + cevap baloncukları
    └── paywall/            # Premium abonelik ekranı
```

**Kullanılan Mimari Pattern: MVVM + Repository**

```
View (Widget) ←→ ViewModel (Riverpod) ←→ Repository ←→ API/LocalDB
```

---

## 🛠️ Teknoloji Yığını

### Frontend
| Paket | Versiyon | Kullanım |
|---|---|---|
| `flutter` | 3.x | Cross-platform UI framework |
| `flutter_riverpod` | ^3.3.1 | State yönetimi |
| `flutter_dotenv` | ^6.0.1 | Güvenli environment variable yönetimi |
| `image_picker` | ^1.2.2 | Galeri/kamera erişimi |
| `flutter_secure_storage` | ^10.3.1 | Hassas veri depolama |
| `google_mobile_ads` | ^8.0.0 | AdMob entegrasyonu |
| `http` | ^1.6.0 | API istekleri |

### Backend / AI
| Servis | Kullanım | Neden? |
|---|---|---|
| **Groq Cloud API** | LLM inference (LLaMA 3) | Ücretsiz tier, düşük latency |
| **Firebase Cloud Functions** *(yol haritası)* | API Proxy | Key güvenliği, rate limiting |
| **AdMob** | Banner & interstitial reklamlar | Freemium gelir |

---

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK >= 3.7.2
- Android Studio / VS Code
- Groq API Key (ücretsiz → [console.groq.com](https://console.groq.com))

### 1. Repoyu Klonla

```bash
git clone https://github.com/godzago/Ne-Cevap-Versem.git
cd Ne-Cevap-Versem/get-shit-done/screat_app
```

### 2. Environment Dosyasını Oluştur

```bash
# .env.example dosyasını kopyala
cp .env.example .env
```

Ardından `.env` dosyasını aç ve kendi API key'ini gir:

```env
GROQ_API_KEY=your_groq_api_key_here
```

> ⚠️ **Asla `.env` dosyasını commit etme!** `.gitignore`'a eklenmiştir.

### 3. Bağımlılıkları Yükle

```bash
flutter pub get
```

### 4. Uygulamayı Çalıştır

```bash
# Emülatör veya bağlı cihazda
flutter run

# Release build
flutter build apk --release
```

---

## 🔐 Güvenlik: API Key Yönetimi

Bu projede 3 katmanlı güvenlik modeli uygulanmaktadır:

```
Katman 1: .env + flutter_dotenv
  → Key kaynak koda yazılmaz
  → .gitignore ile repoya commit edilmez

Katman 2: .env.example (Bu Repo)
  → Şablon dosya örnek key ile paylaşılır
  → Gerçek key paylaşılmaz

Katman 3: Firebase Proxy (Planlanan)
  → İstemci API key'i hiç görmez
  → Tüm istekler sunucu üzerinden akar
```

### Groq API Key Nereden Alınır?

1. [console.groq.com](https://console.groq.com) adresine git
2. Ücretsiz hesap oluştur
3. **API Keys** → **Create API Key**
4. Key'i `.env` dosyana yapıştır

---

## ✅ Özellikler & Yol Haritası

### Tamamlananlar ✅
- [x] 4 persona ile ana ekran
- [x] Groq API entegrasyonu (LLaMA 3)
- [x] 3 alternatif cevap üretimi
- [x] Riverpod state yönetimi
- [x] Güvenli `.env` tabanlı key yönetimi
- [x] AdMob banner reklam entegrasyonu
- [x] Görsel yükleme (image_picker)
- [x] Günlük ücretsiz kredi sistemi (flutter_secure_storage)

### Geliştirme Aşamasında 🔄
- [ ] Firebase Cloud Functions proxy katmanı
- [ ] RevenueCat premium abonelik entegrasyonu
- [ ] OCR — ekran görüntüsünden metin çıkarma
- [ ] Cevap geçmişi (Hive/Isar)

### Yol Haritası 🗺️
- [ ] iOS App Store yayını
- [ ] Çoklu dil desteği (EN, DE, AR)
- [ ] Widget (Ana ekran kısayolu)
- [ ] Siri / Google Asistan entegrasyonu

---

## 📁 Proje Yapısı

```
Ne-Cevap-Versem/
└── get-shit-done/
    └── screat_app/
        ├── lib/
        │   ├── core/
        │   ├── data/
        │   ├── viewmodels/
        │   └── views/
        ├── assets/
        │   ├── 1boss.png       # Patron modu görseli
        │   ├── 2date.png       # Sevgili modu görseli
        │   ├── 3hr.png         # Mülakat modu görseli
        │   └── 4angry.png      # Pasif-agresif mod görseli
        ├── .env.example        # API key şablonu
        ├── pubspec.yaml
        └── README.md
```

---

## 📄 Lisans

Bu proje **MIT Lisansı** altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

<div align="center">

**Ne Cevap Versem?** — *Doğru kelimeyi bulmak artık AI işi.*

Geliştirici ile iletişim için GitHub Issues kullanabilirsiniz.

</div>
