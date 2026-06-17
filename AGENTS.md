# AGENTS.md — screat_app

## Project: "Ne Cevap Vereyim?" Flutter App

Bu Flutter projesi GSD (Get Shit Done) ajanları ile yönetilmektedir.

## GSD Kurulumu

GSD ajanları `.agent/skills/` klasörüne kurulmuştur (67 skill mevcut).

## Temel Kurallar

### Flutter/Dart Geliştirme Standartları
- **Dil:** Dart, Flutter SDK
- **Mimari:** MVVM veya Clean Architecture
- **State Management:** Riverpod veya BLoC
- **Dosya isimlendirme:** `snake_case.dart`
- **Sınıf isimlendirme:** `PascalCase`

### Güvenlik
- API key'ler asla Flutter client'tan doğrudan kullanılmaz
- Tüm AI istekleri Firebase Cloud Functions üzerinden geçer
- `.env` dosyası `.gitignore`'da

### Test
```bash
flutter test
flutter analyze
```

### Build & Run
```bash
flutter run                         # Geliştirme
flutter build apk --release        # Production APK
flutter build appbundle --release  # Google Play
```

## GSD Slash Command Kullanımı

`/gsd` ile başlayan komutlar bu projede doğrudan kullanılabilir:

- `/gsd-quick <görev>` — Hızlı tek görev
- `/gsd-plan-phase` — Yeni bir faz planla
- `/gsd-execute-phase` — Planlanmış fazı uygula
- `/gsd-debug` — Hata ayıklama
- `/gsd-code-review` — Kod incelemesi
- `/gsd-health` — Proje sağlık kontrolü

## Proje Bağlamı

Detaylar için `PROJECT.md` ve `CONTEXT.md` dosyalarına bakın.
