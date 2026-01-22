import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';

import 'package:project_kelompok/screen/misi_page.dart' as misi;
import 'package:project_kelompok/screen/poin_page.dart' as poin;
import 'package:project_kelompok/widget/rewarded_ads.dart';

class FakeAnalytics extends FirebaseAnalyticsPlatform {
  @override
  Future<void> logEvent({
    AnalyticsCallOptions? callOptions,
    required String name,
    Map<String, Object?>? parameters,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    FirebaseAnalyticsPlatform.instance = FakeAnalytics();
    RewardedAds.isTest = true;
  });

  testWidgets('MisiPage menampilkan daftar misi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: misi.MisiPage(
            isTest: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Menanam Pohon'), findsOneWidget);
    expect(find.text('Hemat Air'), findsOneWidget);
    expect(find.text('Daur Ulang'), findsOneWidget);
    expect(find.text('Tonton Iklan'), findsOneWidget);
  });

  testWidgets('PoinPage menampilkan total poin dan reward', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: poin.PoinPage(
            initialPoin: 100,
            isTest: true,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Total Poin Kamu: 100'), findsOneWidget);

    expect(find.text('Voucher Belanja'), findsOneWidget);
    expect(find.text('Merchandise Evergreen'), findsOneWidget);
    expect(find.text('Voucher Makanan'), findsOneWidget);
    expect(find.text('Donasi Tanam Pohon'), findsOneWidget);
  });
}
