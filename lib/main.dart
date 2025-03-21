import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tetris_app/repositories/leaderboard/leaderboard_repository.dart';
import 'package:tetris_app/repositories/leaderboard/leaderboard_repository_impl.dart';
import 'package:tetris_app/repositories/score_repository.dart';
import 'package:tetris_app/repositories/user_repository.dart';
import 'package:tetris_app/service/score/score_service.dart';
import 'package:tetris_app/service/theme/theme_service.dart';
import 'package:tetris_app/utils/helper/net_helper.dart';
import 'package:tetris_app/utils/route_path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialRoute = await getInitialRoute();
  final leaderboardRepository = LeaderboardRepositoryImpl(
    dio: NetworkHelper.dio,
    baseUrl: 'http://1.232.205.46:3000',
  );
  final scoreRepo = ScoreRepository();
  await scoreRepo.init();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => scoreRepo),
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider<LeaderboardRepository>(
          create: (context) => leaderboardRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeService>(create: (context) => ThemeService()),
          BlocProvider<ScoreService>(
            create:
                (context) => ScoreService(
                  scoreRepository: context.read<ScoreRepository>(),
                ),
          ),
        ],
        child: MyApp(initialRoute: initialRoute),
      ),
    ),
  );
}

Future<String> getInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final storedUserId = prefs.getString('userId');
  if (storedUserId != null && storedUserId.trim().isNotEmpty) {
    return RoutePath.home;
  }
  return RoutePath.login;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});
  final String initialRoute;

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      builder:
          (context, child) => Overlay(
            initialEntries: [OverlayEntry(builder: (context) => child!)],
          ),
      theme: context.themeService.themeData,
      initialRoute: initialRoute,
      onGenerateRoute: RoutePath.onGenerateRoute,
    );
  }
}
