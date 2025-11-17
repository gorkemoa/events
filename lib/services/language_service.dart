import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'app_language';
  
  // Varsayılan dil Türkçe
  static const String defaultLanguage = 'tr';
  
  // Desteklenen diller
  static const List<Locale> supportedLocales = [
    Locale('tr', ''), // Türkçe
    Locale('en', ''), // İngilizce
  ];
  
  // Dil adları
  static const Map<String, String> languageNames = {
    'tr': 'Türkçe',
    'en': 'English',
  };
  
  // Kayıtlı dili getir
  static Future<String> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? defaultLanguage;
    } catch (e) {
      return defaultLanguage;
    }
  }
  
  // Dili kaydet
  static Future<void> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }
  
  // Locale'i getir
  static Future<Locale> getSavedLocale() async {
    final languageCode = await getSavedLanguage();
    return Locale(languageCode, '');
  }
}
