import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class ClockText extends StatefulWidget {
  const ClockText({super.key});

  @override
  State<ClockText> createState() => _ClockTextState();
}

class _ClockTextState extends State<ClockText> {
  late Timer _timer;
  String _time = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _updateTime());
  }

  void _updateTime() {
    final formatter = DateFormat('HH:mm');
    setState(() {
      _time = formatter.format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      _time,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }
}
