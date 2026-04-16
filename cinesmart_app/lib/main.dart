import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/auth/login_screen.dart';
import 'routes/app_routes.dart';
import 'services/theme_controller.dart';
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
    // Register ThemeController globally
    final themeController = Get.put(ThemeController());

    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CineSmart',
          theme: ThemeController.lightTheme,
          darkTheme: ThemeController.darkTheme,
          themeMode: themeController.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const LoginScreen(),
          getPages: AppRoutes.routes,
        ));
  }
}