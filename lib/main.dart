import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/root/root_shell.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/auth/pin_entry_screen.dart';
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

          // Главное приложение с PIN защитой
          return MaterialApp(
            title: 'ИИ-ассистент психолога',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: settings.isPinEnabled
                ? PinProtectedHome()
                : const RootShell(),
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

/// Экран с PIN защитой
class PinProtectedHome extends StatefulWidget {
  const PinProtectedHome({super.key});

  @override
  State<PinProtectedHome> createState() => _PinProtectedHomeState();
}

class _PinProtectedHomeState extends State<PinProtectedHome> {
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    if (_isAuthenticated) {
      return const RootShell();
    }

    return PinEntryScreen(
      onSuccess: () {
        setState(() {
          _isAuthenticated = true;
        });
      },
    );
  }
}
