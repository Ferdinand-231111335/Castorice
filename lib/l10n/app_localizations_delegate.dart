import 'package:flutter/material.dart';
import 'package:project_kelompok/l10n/localization.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

class AppLocalizationsDelegate
    extends LocalizationsDelegate<App_Localizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<App_Localizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return AppLocalizationsEn();
      case 'id':
      default:
        return AppLocalizationsId();
    }
  }

  @override
  bool shouldReload(_) => false;
}
