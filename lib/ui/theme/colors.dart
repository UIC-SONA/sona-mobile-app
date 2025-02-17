import 'package:flutter/material.dart';

// COLORS
const primaryColor = Color(0xFF6555B4); // Color base
const accentColor = Color(0xFF5D4FA7); // Ligeramente más oscuro
const turquoiseGreen = Color(0xFF6E60C0); // Más claro
const magenta = Color(0xFF7A6CD0); // Variación 1
const blue = Color(0xFF5C4CA0); // Variación 2
const orange = Color(0xFF8979D8); // Variación 3
const softPink = Color(0xFF8E80DA); // Más brillante
const red = Color(0xFF54459A); // Más saturado
const softGreen = Colors.white; // Mantenemos blanco
const deepMagenta = Color(0xFF4A3F8F); // Base más oscura
const vividMagenta = Color(0xFF7563BE); // Variación clara
const teal = Color(0xFF6050AA); // Variación suave

// COLORS PROVIDED BY CONAGOPARE
const intenseMagenta = Color(0xFF6555B4); // Base
const neonMagenta = Color(0xFF7563BE); // Variación clara
const paleLavanderPink = Color(0xFF8E80DA); // Muy claro
const limeGreen = Color(0xFF6555B4); // Base original
const darkEmeraldGreen = Color(0xFF5D4FA7); // Más oscuro

const hintColor = Color(0xFFA9A9A9); // Gris sin cambios

// GRADIENTS
const bgGradientMagenta = LinearGradient(
  colors: [
    Color(0xFF9C8BFA),
    Color(0xFFACA0E5),
    Color(0xFFB8AEF3),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

const bgGradientLight = LinearGradient(
  colors: [
    Color(0xFFCCC9F8),
    Color(0xFF8179A8),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

//GRADIENT BUTTON 1
const bgGradientButton1 = LinearGradient(
  colors: [
    Color(0xFF6555B4),
    Color(0xFF7563BE),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

//GRADIENT BUTTON 2
const bgGradientButton2 = LinearGradient(
  colors: [
    Color(0xFF8E80DA),
    Color(0xFF6555B4),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

//GRADIENT HEADER
const bgGradientAppBar = LinearGradient(
  colors: [
    Color(0xFF7563BE),
    Color(0xFF6555B4),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

//GRADIENT NOTIFICATION
const bgGradientNotification = LinearGradient(
  colors: [
    Color(0xFFFFFFFF),
  ],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

//GRADIENT BACK PROFESIONAL
const bgGradientBackProfesional = LinearGradient(
  colors: [Color(0xFF6555B4), Color(0xFF8E80DA)],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);

//GRADIENT BACK CHATBOT
const bgGradientBackChatbot = LinearGradient(
  colors: [Color(0xFF6555B4), Color(0xFF7563BE)],
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
);
