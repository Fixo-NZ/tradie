import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/views/profile_setup_screen.dart';

// Toggle this to true to run the app directly on the ProfileSetupScreen.
// Set to false to use the normal router behavior.
const bool kLaunchProfileSetupDirectly = true;

void main() {
 runApp(const ProviderScope(child: TradieApp()));
}

class TradieApp extends ConsumerWidget {
 const TradieApp({super.key});

 @override
 Widget build(BuildContext context, WidgetRef ref) {
   final router = ref.watch(routerProvider);
  
   // Run app directly to Profile Setup (for testing purposes)
   if (kLaunchProfileSetupDirectly) {
     return MaterialApp(
       title: 'Tradie - Profile Setup',
       debugShowCheckedModeBanner: false,
       theme: AppTheme.lightTheme,
       darkTheme: AppTheme.darkTheme,
       themeMode: ThemeMode.system,
       home: const ProfileSetupScreen(),
     );
   }

   return MaterialApp.router(
     title: 'Tradie',
     debugShowCheckedModeBanner: false,
     theme: AppTheme.lightTheme,
     darkTheme: AppTheme.darkTheme,
     themeMode: ThemeMode.system,
     routerConfig: router,
   );
 }
}
