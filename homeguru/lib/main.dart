import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/welcome/welcome_screen.dart';

const _kThemeKey = 'theme_mode';

final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

Future<void> _loadTheme() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kThemeKey);
  themeModeNotifier.value =
      saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
}

Future<void> saveTheme(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
      _kThemeKey, mode == ThemeMode.dark ? 'dark' : 'light');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow google_fonts to cache downloaded fonts to disk —
  // after first run fonts load instantly even offline.
  GoogleFonts.config.allowRuntimeFetching = false;

  await _loadTheme();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const HomeGuruApp());
}

class HomeGuruApp extends StatelessWidget {
  const HomeGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = harmonise(lightDynamic, Brightness.light);
        final darkScheme = harmonise(darkDynamic, Brightness.dark);

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          // child is the part that never changes — avoids rebuilding WelcomeScreen
          child: const WelcomeScreen(),
          builder: (context, mode, child) => MaterialApp(
            title: 'HomeGuru',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(lightScheme),
            darkTheme: buildTheme(darkScheme),
            themeMode: mode,
            home: child,
          ),
        );
      },
    );
  }
}
