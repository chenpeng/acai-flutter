import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static SharedPreferences prefs;

  static Future init(String baseUrl) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString('baseUrl', baseUrl);
  }
}
