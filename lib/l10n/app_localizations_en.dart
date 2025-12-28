import 'dart:ui';

import 'package:project_kelompok/l10n/localization.dart';

class AppLocalizationsEn extends App_Localizations {
  AppLocalizationsEn() : super(const Locale('en'));

  @override
  String get signIn => 'Sign In';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInButton => 'Sign In';

  @override
  String get dontHaveAccount => "Don't have an account? Sign Up";

  @override
  String get signInPage => 'Sign In Page';
}
