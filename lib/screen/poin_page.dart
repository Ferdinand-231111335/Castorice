import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class PoinPage extends StatefulWidget {
  const PoinPage({super.key});

  @override
  State<PoinPage> createState() => _PoinPageState();
}

class _PoinPageState extends State<PoinPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  int totalPoin = 0;
  String get uid => _auth.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _requestNotifPermission();
    _loadPoin();
    _scheduleMisiReminder();
    _scheduleVoucherExpiredNotifTest();
  }

  Future<void> _requestNotifPermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  int _generateNotifId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> _loadPoin() async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        totalPoin = doc['poin'] ?? 0;
      });
    }
  }

  Future<void> _showRedeemNotification(String hadiah, int biaya) async {
    final prefs = await SharedPreferences.getInstance();
    final isNotifEnabled = prefs.getBool('isNotificationEnabled') ?? true;
    if (!isNotifEnabled) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _generateNotifId(),
        channelKey: 'basic_channel',
        title: "Penukaran Berhasil 🎉",
        body: "$biaya poin berhasil ditukar dengan $hadiah",
        category: NotificationCategory.Status,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
        ),
      ],
    );
  }

  Future<void> _scheduleMisiReminder() async {
    final now = DateTime.now().add(const Duration(seconds: 10));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _generateNotifId(),
        channelKey: 'basic_channel',
        title: "Ayo Kerjakan Misi 🌱",
        body: "Kamu belum mengerjakan misi hari ini.",
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
        ),
      ],
      schedule: NotificationCalendar(
        year: now.year,
        month: now.month,
        day: now.day,
        hour: now.hour,
        minute: now.minute,
        second: now.second,
        millisecond: 0,
      ),
    );
  }

  Future<void> _scheduleVoucherExpiredNotifTest() async {
    final now = DateTime.now().add(const Duration(seconds: 15));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _generateNotifId(),
        channelKey: 'basic_channel',
        title: "Voucher Hampir Kedaluwarsa ⏰",
        body: "Segera gunakan voucher kamu sebelum expired!",
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
          actionType: ActionType.DismissAction,
        ),
      ],
      schedule: NotificationCalendar(
        year: now.year,
        month: now.month,
        day: now.day,
        hour: now.hour,
        minute: now.minute,
        second: now.second,
        millisecond: 0,
      ),
    );
  }

  Future<void> _redeemPoin(int biaya, String hadiah) async {
    if (totalPoin < biaya) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Poin tidak cukup untuk $hadiah")));
      return;
    }

    final userRef = _firestore.collection('users').doc(uid);
    final ticketRef = userRef.collection('tickets').doc();

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final currentPoin = snapshot['poin'];

      transaction.update(userRef, {'poin': currentPoin - biaya});
      transaction.set(ticketRef, {
        'hadiah': hadiah,
        'poin': biaya,
        'tanggal': FieldValue.serverTimestamp(),
      });
    });

    analytics.logEvent(
      name: "redeem_success",
      parameters: {"hadiah": hadiah, "biaya": biaya},
    );

    await _loadPoin();
    await _showRedeemNotification(hadiah, biaya);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Berhasil menukar $biaya poin untuk $hadiah")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "Total Poin Kamu: $totalPoin",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const Divider(thickness: 2),
        Expanded(
          child: ListView(
            children: [
              _buildItem("Voucher Belanja", 50, Icons.shopping_cart),
              _buildItem("Merchandise Evergreen", 80, Icons.card_giftcard),
              _buildItem("Voucher Makanan", 100, Icons.fastfood),
              _buildItem("Donasi Tanam Pohon", 200, Icons.park),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String hadiah, int biaya, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(hadiah),
      subtitle: Text("Tukar dengan $biaya poin"),
      trailing: ElevatedButton(
        onPressed: () => _redeemPoin(biaya, hadiah),
        child: const Text("Tukar"),
      ),
    );
  }
}