import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible_home.dart';

void main() {
  runApp(const WOGBibleApp());
}

class WOGBibleApp extends StatelessWidget {
  const WOGBibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WOG Bible',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Black Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black87,
          elevation: 0,
        ),
        // Ramabhadra Telugu Font అప్లై చేయడం
        textTheme: GoogleFonts.ramabhadraTextTheme(
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
