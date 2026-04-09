import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'dart:io';

// 🔐 FIX SSL ISSUE (DEV ONLY)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const CineSmartApp());
}

class CineSmartApp extends StatelessWidget {
  const CineSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineSmart',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE11D48), // BMS-ish pink/red
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEAEAF0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFEAEAF0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE11D48), width: 1.4),
          ),
        ),
      ),

      home: const LoginScreen(),
    );
  }
}