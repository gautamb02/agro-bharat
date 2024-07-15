import 'package:flutter/material.dart';
import 'package:agro_bharat/services/localmanager.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', '');
  final LocaleManager _localeManager = LocaleManager();

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  void _loadSavedLocale() async {
    final savedLocale = await _localeManager.getLocale();
    if (savedLocale != null) {
      setLocale(Locale(savedLocale));
    }
  }

  void setLocale(Locale locale) {
    if (_locale != locale) {
      _locale = locale;
      _localeManager.setLocale(locale.languageCode);
      notifyListeners();
    }
  }
}