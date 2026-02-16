import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String googleMapsApiKey;
  static late String databasePath;
  static late String appName;
  static late String appVersion;

  // Firebase credentials
  static late String firebaseApiKey;
  static late String firebaseAppId;
  static late String firebaseMessagingSenderId;
  static late String firebaseProjectId;

  // Cargar configuración desde .env
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");

    googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    databasePath = dotenv.env['DATABASE_PATH'] ?? 'puestos.db';
    appName = dotenv.env['APP_NAME'] ?? 'Gestión de Puestos';
    appVersion = dotenv.env['APP_VERSION'] ?? '1.0.0';

    // Firebase credentials
    firebaseApiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
    firebaseAppId = dotenv.env['FIREBASE_APP_ID'] ?? '';
    firebaseMessagingSenderId =
        dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
    firebaseProjectId = dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

    if (googleMapsApiKey.isEmpty) {
      throw Exception(
        'GOOGLE_MAPS_API_KEY no está definida en .env. '
        'Copia .env.example a .env y agregua tu API Key.',
      );
    }

    if (firebaseApiKey.isEmpty || firebaseProjectId.isEmpty) {
      throw Exception(
        'Credenciales de Firebase no están definidas en .env. '
        'Verifica que FIREBASE_API_KEY y FIREBASE_PROJECT_ID existan.',
      );
    }
  }
}
