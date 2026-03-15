import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WOGBibleApp());
}

class WOGBibleApp extends StatelessWidget {
  const WOGBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WOG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep Black
        // యాప్ మొత్తం Baloo Tammudu 2 ఫాంట్ అప్లై చేయడానికి
        textTheme: GoogleFonts.balooTammudu2TextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
      ),
      home: const BibleHome(),
    );
  }
}
