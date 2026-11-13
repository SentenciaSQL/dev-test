# AppTrial Mobile (Flutter)

Aplicación Android exclusiva. Nombre comercial pendiente.

## Stack

- Flutter estable + Dart
- Material Design 3
- Riverpod, GoRouter, Dio, Flutter Secure Storage

## Organización

`lib/features/<feature>/{presentation,domain,data}` + `lib/core`.

## Ejecutar

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

No se generan tests automatizados en este proyecto.
