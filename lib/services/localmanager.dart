import 'package:shared_preferences/shared_preferences.dart';

class LocaleManager {
  static const String _localeKey = 'selectedLocale';

  Future<void> setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale);
  }

  Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }
}
