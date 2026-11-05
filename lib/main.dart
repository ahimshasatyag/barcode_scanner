import 'package:flutter/material.dart';
import 'features/splash/splash.dart';
import 'shared/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BarcodeApp());
}

class BarcodeApp extends StatefulWidget {
  const BarcodeApp({super.key});

  @override
  State<BarcodeApp> createState() => _BarcodeAppState();
}

class _BarcodeAppState extends State<BarcodeApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eka Maju Mesinindo - Barcode',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: SplashScreen(
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
