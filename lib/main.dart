import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(const OrinApp());
}

/// Visual Intelligence Command Center
/// A premium mobile app for managing camera spaces,
/// AI-powered Guards, and reviewing important events
class OrinApp extends StatelessWidget {
  const OrinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orin',
      debugShowCheckedModeBanner: false,

      // Apple-inspired theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // Start with splash screen
      home: const SplashScreen(),
    );
  }
}
