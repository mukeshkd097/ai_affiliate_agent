import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/screenshot/screenshot_bloc.dart';
import 'constants/app_constants.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'services/category_service.dart';
import 'services/database_service.dart';
import 'services/photo_service.dart';
import 'services/subscription_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final prefs = await SharedPreferences.getInstance();
  final isOnboardingComplete =
      prefs.getBool(AppConstants.keyOnboardingComplete) ?? false;

  final dbService = DatabaseService();
  await dbService.init();

  final categoryService = CategoryService();
  final photoService = PhotoService();
  final subscriptionService = SubscriptionService(prefs);

  runApp(SnapSortApp(
    isOnboardingComplete: isOnboardingComplete,
    dbService: dbService,
    categoryService: categoryService,
    photoService: photoService,
    subscriptionService: subscriptionService,
  ));
}

class SnapSortApp extends StatelessWidget {
  final bool isOnboardingComplete;
  final DatabaseService dbService;
  final CategoryService categoryService;
  final PhotoService photoService;
  final SubscriptionService subscriptionService;

  const SnapSortApp({
    super.key,
    required this.isOnboardingComplete,
    required this.dbService,
    required this.categoryService,
    required this.photoService,
    required this.subscriptionService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: dbService),
        RepositoryProvider.value(value: categoryService),
        RepositoryProvider.value(value: photoService),
        RepositoryProvider.value(value: subscriptionService),
      ],
      child: BlocProvider(
        create: (context) => ScreenshotBloc(
          dbService: dbService,
          categoryService: categoryService,
          photoService: photoService,
        ),
        child: MaterialApp(
          title: 'SnapSort AI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: isOnboardingComplete
              ? const HomeScreen()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}
