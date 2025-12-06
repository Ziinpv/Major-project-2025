import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/router.dart';
import 'core/providers/app_theme_provider.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/text_scale_provider.dart';
import 'core/services/notification_service.dart';
import 'data/providers/socket_connection_provider.dart';
import 'l10n/app_localizations.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize notification service
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: MatchaApp(),
    ),
  );
}

class MatchaApp extends ConsumerWidget {
  const MatchaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize socket connection based on auth state
    ref.watch(socketConnectionProvider);
    
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(appThemeProvider);
    final textScale = ref.watch(textScaleProvider);
    final languageCode = ref.watch(languageProvider);

    // Define custom color palette
    const colorPrimary = Color(0xFFF5AFAF); // Hồng Pastel đậm
    const colorSecondary = Color(0xFFF9DFDF); // Hồng phấn
    const colorBackground = Color(0xFFFBEFEF); // Hồng rất nhạt
    const colorSurface = Color(0xFFFCF8F8); // Trắng ánh hồng
    const colorError = Color(0xFFE57373); // Hồng đỏ cho lỗi

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: colorPrimary,
        secondary: colorSecondary,
        surface: colorSurface,
        error: colorError,
        onPrimary: Colors.black, // Text on Primary
        onSecondary: Colors.black, // Text on Secondary
        onSurface: Colors.black87, // Text on Surface
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: colorBackground,
      primaryColor: colorPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: colorSurface,
        surfaceTintColor: Colors.transparent, // Remove overlay color
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        color: colorSurface,
        elevation: 2,
        shadowColor: Colors.black12,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: Colors.black87,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorSecondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorSecondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      fontFamily: 'Roboto',
    );

    // Dark Theme (Adapted for Dark Mode while keeping the pink essence)
    final darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: colorPrimary, // Keep primary pink
        secondary: Color(0xFF8C5A5A), // Darker pink for secondary
        surface: Color(0xFF2C2222), // Dark pink-brown surface
        background: Color(0xFF1A1616), // Very dark background
        error: colorError,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Color(0xFFECECEC),
        onBackground: Color(0xFFECECEC),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1616),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C2222),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFFECECEC),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2C2222),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2222),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8C5A5A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8C5A5A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorPrimary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF2C2222),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF2C2222),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      fontFamily: 'Roboto',
    );

    return MaterialApp.router(
      title: 'Matcha',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      
      // Localization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', ''),
        Locale('en', ''),
      ],
      locale: Locale(languageCode),
      
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(textScale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}

