import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_state.dart';

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() { super.initState(); Timer(const Duration(milliseconds: 1100), () { if (mounted) context.go(appState.signedIn ? '/dashboard' : '/login'); }); }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 76, height: 76, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 38)),
    const SizedBox(height: 20), const Text('KARSU', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: 3)),
    const SizedBox(height: 6), const Text('BUILD. GROW. HIT.', style: TextStyle(color: AppColors.textSecondary, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.w700)),
  ])));
}
