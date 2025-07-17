import 'package:dicabs/core/color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DTheme{
  const DTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: DColor.primaryColor,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      surface: Colors.white,
      primary: DColor.primaryColor,
      secondary: Colors.white,
      onSurface: Colors.black,
    ),
      textTheme: TextTheme(
        bodyLarge: GoogleFonts.inter(
            color: DColor.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w700
        ),
        bodyMedium: GoogleFonts.inter(
            color: DColor.lightText,
            fontSize: 12,
            fontWeight: FontWeight.w600
        ),
        bodySmall: GoogleFonts.inter(
            color: DColor.lightText,
            fontSize: 10,
            fontWeight: FontWeight.normal
        ),
        labelLarge:   GoogleFonts.inter(
          color: DColor.lightText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium:  GoogleFonts.inter(
          color: DColor.lightText,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          color: hexToColor("#5D6E83"),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: DColor.primaryColor,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: const ColorScheme.dark(
      surface: Colors.black,
      primary: DColor.primaryColor,
      secondary: Colors.black,
      onSurface: Colors.white
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.inter(
        color: DColor.darkText,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: GoogleFonts.inter(
          color: DColor.darkText,
          fontSize: 12,
          fontWeight: FontWeight.w600
      ),
      bodySmall: GoogleFonts.inter(
        color: DColor.darkText,
        fontSize: 10,
        fontWeight: FontWeight.normal,
      ),
      labelLarge:   GoogleFonts.inter(
        color: DColor.darkText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      labelMedium:  GoogleFonts.inter(
        color: DColor.darkText,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.inter(
        color: DColor.darkText,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}