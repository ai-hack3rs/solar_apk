import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/calculator_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => CalculatorProvider(),
      child: const SolarCalculatorApp(),
    ),
  );
}

class SolarCalculatorApp extends StatelessWidget {
  const SolarCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solar Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFB300),
          brightness: Brightness.dark,
          primary: const Color(0xFFFFB300),
          secondary: const Color(0xFFFF6F00),
          surface: const Color(0xFF1A1A2E),
          onPrimary: Colors.black,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1E),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E35),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF252540),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFFB300), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFFAAAAAA)),
          hintStyle: const TextStyle(color: Color(0xFF666680)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB300),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: Color(0xFFFFB300),
          thumbColor: Color(0xFFFFB300),
          overlayColor: Color(0x33FFB300),
          inactiveTrackColor: Color(0xFF333355),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
