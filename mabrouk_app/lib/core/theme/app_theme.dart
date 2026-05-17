import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sizer/sizer.dart';

class AppTheme {
  static const primaryMaroon = Color(0xFF800000);
  static const luxuryBeige = Color(0xFFFFF8EE);
  static const accentGold = Color(0xFFD4AF37);

  static List<BoxShadow> get3DShadows({bool isSelected = false}) {
    if (isSelected) {
      return [
        BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(1.w, 1.w), blurRadius: 2.w),
        BoxShadow(color: Colors.white.withOpacity(0.2), offset: Offset(-0.5.w, -0.5.w), blurRadius: 1.w),
      ];
    }
    return [
      BoxShadow(color: Colors.black.withOpacity(0.15), offset: Offset(0.8.w, 0.8.w), blurRadius: 1.2.w),
      BoxShadow(color: Colors.white.withOpacity(0.6), offset: Offset(-0.3.w, -0.3.w), blurRadius: 0.5.w),
    ];
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryMaroon,
      scaffoldBackgroundColor: luxuryBeige,
      fontFamily: GoogleFonts.cairo().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMaroon,
        primary: primaryMaroon,
        secondary: accentGold,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryMaroon,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold, 
          fontSize: 16.sp,
          letterSpacing: 1.1,
        ),
      ),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMaroon,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 6.w),
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(4.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: const BorderSide(color: primaryMaroon, width: 2),
        ),
      ),
    );
  }
}
