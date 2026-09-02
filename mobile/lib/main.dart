import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'core/state/app_state.dart';

Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await appState.initialize(); runApp(const KarsuApp()); }
class KarsuApp extends StatelessWidget { const KarsuApp({super.key}); @override Widget build(BuildContext context)=>MaterialApp.router(title:'KARSU',debugShowCheckedModeBanner:false,theme:AppTheme.dark,routerConfig:appRouter); }
