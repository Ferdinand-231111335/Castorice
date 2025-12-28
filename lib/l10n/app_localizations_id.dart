import 'dart:ui';

import 'package:project_kelompok/l10n/localization.dart';

class AppLocalizationsId extends App_Localizations {
  AppLocalizationsId() : super(const Locale('id'));

  @override
  String get signIn => 'Masuk';

  @override
  String get email => 'Email';

  @override
  String get password => 'Kata Sandi';

  @override
  String get signInButton => 'Masuk';

  @override
  String get dontHaveAccount => 'Belum punya akun? Daftar';

  @override
  String get signInPage => 'Halaman Masuk';
}
