import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme/app_theme.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/dashboard/learner/learner_dashboard.dart';
import 'screens/dashboard/learner/search_results_screen.dart';
import 'screens/dashboard/tutor/tutor_dashboard.dart';
import 'screens/shared/guruai/guruai_screen.dart';
import 'screens/onboarding/tutor_onboarding_screen.dart';
import 'screens/onboarding/learner_onboarding_screen.dart';
import 'services/user_profile_store.dart';
import 'services/call_notification_service.dart';

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

  // Initialize call notification service
  await CallNotificationService.initialize();

  // Enable google_fonts runtime fetching
  GoogleFonts.config.allowRuntimeFetching = true;

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
    final authToken = prefs.getString('authToken');
    final userId = prefs.getString('userId');
    final userRole = prefs.getString('userRole');
    
    if (authToken != null && userId != null && userRole != null) {
      // User is logged in
      if (userRole == 'learner') {
        // Check onboarding status for learner
        try {
          final response = await http.get(
            Uri.parse('https://app.homeguruworld.com/api/onboarding/learner/register?learnerId=$userId'),
          );
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (mounted) {
              setState(() {
                if (data['success'] == true && data['data']['onboardingComplete'] == true) {
                  _initialRoute = const LearnerDashboard();
                } else {
                  // Resume onboarding
                  final step = data['data']['currentStep'] ?? 'source';
                  _initialRoute = LearnerOnboardingScreen(resumeStep: step);
                }
              });
            }
          } else {
            // API error, go to dashboard
            if (mounted) {
              setState(() => _initialRoute = const LearnerDashboard());
            }
          }
        } catch (e) {
          // Network error, go to dashboard
          if (mounted) {
            setState(() => _initialRoute = const LearnerDashboard());
          }
        }
      } else if (userRole == 'tutor') {
        // Check onboarding status for tutor
        try {
          final response = await http.get(
            Uri.parse('https://app.homeguruworld.com/api/onboarding/tutor/register?tutorId=$userId'),
          );
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (mounted) {
              setState(() {
                if (data['success'] == true && data['data']['onboardingComplete'] == true) {
                  _initialRoute = const TutorDashboard();
                } else {
                  // Resume onboarding
                  final step = data['data']['currentStep'] ?? 'profile';
                  _initialRoute = TutorOnboardingScreen(resumeStep: step);
                }
              });
            }
          } else {
            // API error, go to dashboard
            if (mounted) {
              setState(() => _initialRoute = const TutorDashboard());
            }
          }
        } catch (e) {
          // Network error, go to dashboard
          if (mounted) {
            setState(() => _initialRoute = const TutorDashboard());
          }
        }
      } else {
        if (mounted) {
          setState(() => _initialRoute = const WelcomeScreen());
        }
      }
    } else {
      // Not logged in
      if (mounted) {
        setState(() => _initialRoute = const WelcomeScreen());
      }
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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              FlutterQuillLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: _initialRoute,
            routes: {
              '/learner-dashboard': (context) => const LearnerDashboard(),
              '/tutor-dashboard': (context) => const TutorDashboard(),
              '/guru-ai': (context) => const GuruAIScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/search-results') {
                final query = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (context) => SearchResultsScreen(initialQuery: query),
                );
              }
              if (settings.name == '/tutor-onboarding') {
                final args = settings.arguments as Map<String, dynamic>?;
                final resumeStep = args?['resumeStep'] as String?;
                return MaterialPageRoute(
                  builder: (context) => TutorOnboardingScreen(resumeStep: resumeStep),
                );
              }
              if (settings.name == '/learner-onboarding') {
                final args = settings.arguments as Map<String, dynamic>?;
                final resumeStep = args?['resumeStep'] as String?;
                return MaterialPageRoute(
                  builder: (context) => LearnerOnboardingScreen(resumeStep: resumeStep),
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
