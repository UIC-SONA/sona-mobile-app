import 'package:flutter/material.dart';
import 'package:sona/ui/theme/colors.dart';

const borderRadius = BorderRadius.all(Radius.circular(10));

final theme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: softGreen,
  primaryColor: primaryColor,
  colorScheme: ColorScheme.fromSwatch(
    accentColor: accentColor,
    brightness: Brightness.light,
    primarySwatch: MaterialColor(primaryColor.value, const {
      50: Color(0xFFE0B3D1),
      100: Color(0xFFC680B3),
      200: Color(0xFFA94D94),
      300: Color(0xFF8C1A76),
      400: Color(0xFF7A005F),
      500: primaryColor,
      600: Color(0xFF6E004F),
      700: Color(0xFF5C0043),
      800: Color(0xFF4A0037),
      900: Color(0xFF2D0020),
    }),
  ),
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    backgroundColor: deepMagenta,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(deepMagenta),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    focusColor: deepMagenta,
    labelStyle: TextStyle(color: hintColor),
    floatingLabelStyle: TextStyle(color: deepMagenta),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: hintColor, width: 1),
      borderRadius: borderRadius,
    ),
    disabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: hintColor, width: 1),
      borderRadius: borderRadius,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: deepMagenta, width: 2),
      borderRadius: borderRadius,
    ),
    outlineBorder: BorderSide(color: hintColor, width: 1),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
      borderRadius: borderRadius,
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
      borderRadius: borderRadius,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.all<double>(1),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return hintColor;
        }
        return deepMagenta;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      surfaceTintColor: WidgetStateProperty.all<Color>(Colors.white),
      iconColor: WidgetStateProperty.all<Color>(Colors.white),
      shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: borderRadius)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
      foregroundColor: WidgetStateProperty.all<Color>(deepMagenta),
      side: WidgetStateProperty.all<BorderSide>(const BorderSide(color: deepMagenta)),
      surfaceTintColor: WidgetStateProperty.all<Color>(deepMagenta),
      shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: borderRadius)),
    ),
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: softGreen,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all<Color>(deepMagenta),
    trackColor: WidgetStateProperty.all<Color>(softPink),
  ),
);
