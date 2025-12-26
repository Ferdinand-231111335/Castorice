import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'screen/signin.dart';
import 'l10n/app_localizations_delegate.dart';

typedef ThemeChangeCallback = void Function(bool isDarkMode);
typedef LocaleChangeCallback = void Function(Locale locale);

FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel',
      defaultColor: Colors.green,
      importance: NotificationImportance.High,
    ),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  Locale _locale = const Locale('id');

  void _toggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  void _changeLocale(Locale locale) {
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// 🔥 KUNCI LANGUAGE SWITCH
      locale: _locale,
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      title: 'Evergreen App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],

      /// 🔥 KUNCI KEDUA: KIRIM CALLBACK KE PAGE
      home: SignIn(toggleTheme: _toggleTheme, changeLocale: _changeLocale),
    );
  }
}
