import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/root/root_shell.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'providers/app_settings_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/mood_provider.dart';
import 'providers/exercise_provider.dart';

void main() {
  runApp(const PsychoAiAssistantApp());
}

class PsychoAiAssistantApp extends StatelessWidget {
  const PsychoAiAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => MoodProvider()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          // Если настройки ещё не загружены, показываем splash
          if (!settings.isInitialized) {
            return MaterialApp(
              title: 'ИИ-ассистент психолога',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              home: const SplashScreen(),
            );
          }

          // Если онбординг не пройден, показываем онбординг
          if (!settings.isOnboardingCompleted) {
            return MaterialApp(
              title: 'ИИ-ассистент психолога',
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              home: const OnboardingFlow(),
              routes: {
                '/home': (context) => const RootShell(),
                '/onboarding': (context) => const OnboardingFlow(),
              },
            );
          }

          // Иначе показываем главное приложение
          return MaterialApp(
            title: 'ИИ-ассистент психолога',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const RootShell(),
            routes: {
              '/home': (context) => const RootShell(),
              '/onboarding': (context) => const OnboardingFlow(),
            },
          );
        },
      ),
    );
  }
}
