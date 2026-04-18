import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/scenario/scenario_selection_screen.dart';
import 'screens/character/character_selection_screen.dart';
import 'screens/conversation/conversation_screen.dart';
import 'screens/feedback/feedback_screen.dart';

/// App widget — MaterialApp with routing and theme
class RealTalkApp extends StatelessWidget {
  const RealTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppConstants.routeLogin,
      routes: {
        AppConstants.routeLogin: (context) => const LoginScreen(),
        AppConstants.routeHome: (context) => const HomeScreen(),
        AppConstants.routeScenarioSelect: (context) =>
            const ScenarioSelectionScreen(),
        AppConstants.routeCharacterSelect: (context) =>
            const CharacterSelectionScreen(),
        AppConstants.routeConversation: (context) =>
            const ConversationScreen(),
        AppConstants.routeFeedback: (context) => const FeedbackScreen(),
      },
      // Page transitions
      onGenerateRoute: (settings) {
        // Use custom transitions for smoother navigation
        Widget page;
        switch (settings.name) {
          case AppConstants.routeConversation:
            page = const ConversationScreen();
            break;
          case AppConstants.routeFeedback:
            page = const FeedbackScreen();
            break;
          default:
            return null;
        }

        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: child,
            );
          },
          transitionDuration: AppConstants.animMedium,
        );
      },
    );
  }
}
