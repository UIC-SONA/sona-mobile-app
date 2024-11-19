import 'package:flutter/cupertino.dart';
import 'package:sona/application/navigation/home.dart';
import 'package:sona/application/navigation/login.dart';
import 'package:sona/application/navigation/menu_options.dart';
import 'package:sona/application/navigation/signup.dart';
import 'package:sona/application/navigation/services_options.dart';
import 'package:sona/application/navigation/splash.dart';
import 'package:sona/features/chatbot/screens/chat_bot.dart';
import 'package:sona/features/menstrualcalendar/screens/menstrual_calendar.dart';
import 'package:sona/features/tips/screens/list_tips.dart';

final Map<String, WidgetBuilder> routes = {
  '/': (context) => const SplashScreen(),
  '/login': (context) => const LoginPage(),
  '/home': (context) => const HomeScreen(),
  '/register': (context) => const SignUpPage(),
  '/menstrual-calendar': (context) => const MenstrualCalendar(),
  '/options': (context) => const MenuOptions(),
  '/services': (context) => const ServicesOptions(),
  '/chatbot': (context) => const ChatBotScreen(),
  '/tips': (context) => const ListTips(),
};

const initialRoute = '/';
