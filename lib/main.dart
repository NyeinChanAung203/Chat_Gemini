import 'package:chat_bot/onboarding.dart';
import 'package:chat_bot/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Consumer(
        builder: (context, ref, child) => MaterialApp(
          title: 'Gemini Chat Bot',
          themeMode: ref.watch(themeProvider),
          darkTheme: AppTheme.darkTheme,
          theme: AppTheme.lightTheme,
          home: const Onboarding(),
        ),
      ),
    );
  }
}
