# 🚗 RutaPlaca

App Android para consultar el pico y placa en las principales ciudades de Colombia. Desarrollada en Flutter.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?logo=android)](https://developer.android.com)

---

## ¿De qué va esto?

RutaPlaca nació porque buscar el pico y placa a diario es un dolor. La idea es simple: ingresas tu placa, seleccionas tu ciudad y la app te dice si puedes circular hoy. Además te manda una notificación antes de que empiece la restricción para que no te pille desprevenido.

Está hecha con Flutter para Android, monetizada con AdMob y pensada para conductores colombianos.

---

## Funcionalidades principales

- Consulta de pico y placa por ciudad y placa
- Notificaciones antes de que empiece la restricción
- Widget para la pantalla de inicio
- Soporte para guardar varios vehículos
- Funciona sin internet para consultas básicas

**Ciudades disponibles:** Bogotá, Medellín, Cali (más ciudades en camino)

---

## Stack

- **Flutter / Dart** — todo el frontend y lógica
- **Flutter Local Notifications** — notificaciones
- **Home Widget** — widget de pantalla de inicio
- **SharedPreferences** — persistencia local
- **Google AdMob** — anuncios

---

## Correr el proyecto localmente

Necesitas Flutter 3.x instalado. Luego:

```bash
git clone https://github.com/pablo-briceno-dev/ruta-placa-app.git
cd ruta-placa-app
flutter pub get
flutter run
```

Para los IDs de AdMob, crea el archivo `lib/config/secrets.dart` (está en `.gitignore`):

```dart
const String admobAppId = 'ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX';
const String admobBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

---

## Contacto

Pablo Briceño — [pablo-briceno-dev.vercel.app](https://pablo-briceno-dev.vercel.app) — pablo.briceno.dev@gmail.com

Hecho en Colombia 🇨🇴