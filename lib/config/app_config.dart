import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String googleMapsApiKey;
  static late String databasePath;
  static late String appName;
  static late String appVersion;

  // Cargar configuración desde .env
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");

    googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    databasePath = dotenv.env['DATABASE_PATH'] ?? 'puestos.db';
    appName = dotenv.env['APP_NAME'] ?? 'Gestión de Puestos';
    appVersion = dotenv.env['APP_VERSION'] ?? '1.0.0';

    if (googleMapsApiKey.isEmpty) {
      throw Exception(
        'GOOGLE_MAPS_API_KEY no está definida en .env. '
        'Copia .env.example a .env y agregua tu API Key.',
      );
    }
  }
}
