import 'package:flutter/material.dart';

abstract class App_Localizations {
  final Locale locale;
  App_Localizations(this.locale);

  static App_Localizations of(BuildContext context) {
    return Localizations.of<App_Localizations>(context, App_Localizations)!;
  }

  String get signIn;
  String get email;
  String get password;
  String get signInButton;
  String get dontHaveAccount;
  String get signInPage;
}
