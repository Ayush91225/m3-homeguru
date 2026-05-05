import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'theme/app_theme.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/dashboard/learner/learner_dashboard.dart';
import 'screens/dashboard/learner/search_results_screen.dart';
import 'screens/shared/guruai/guruai_screen.dart';
import 'services/user_profile_store.dart';

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

late final UserProfileStore profileStore;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();

  // Disable google_fonts runtime fetching for better performance
  GoogleFonts.config.allowRuntimeFetching = false;

  await _loadTheme();
  profileStore = await UserProfileStore.load();
  
  // Edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  // Reduce memory usage on low-end devices
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );
  
  runApp(ProfileStore(store: profileStore, child: const HomeGuruApp()));
}

class HomeGuruApp extends StatefulWidget {
  const HomeGuruApp({super.key});

  @override
  State<HomeGuruApp> createState() => _HomeGuruAppState();
}

class _HomeGuruAppState extends State<HomeGuruApp> {
  Widget? _initialRoute;

  @override
  void initState() {
    super.initState();
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInUser = prefs.getString('logged_in_user');
    
    if (mounted) {
      setState(() {
        if (loggedInUser == 'learner') {
          _initialRoute = const LearnerDashboard();
        } else {
          _initialRoute = const WelcomeScreen();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = harmonise(lightDynamic, Brightness.light);
        final darkScheme = harmonise(darkDynamic, Brightness.dark);

        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) => MaterialApp(
            title: 'HomeGuru',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(lightScheme),
            darkTheme: buildTheme(darkScheme),
            themeMode: mode,
            home: _initialRoute,
            routes: {
              '/learner-dashboard': (context) => const LearnerDashboard(),
              '/guru-ai': (context) => const GuruAIScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/search-results') {
                final query = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (context) => SearchResultsScreen(initialQuery: query),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
