import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutrilens/utils/size_config.dart';
import 'routes/router.dart';
import 'cubit/theme/theme_cubit.dart';
import 'theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'cubit/home/home_cubit.dart';
import 'repo/gemini_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");


  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  final statuses = await [
    Permission.camera,
    Permission.photos,
    Permission.storage,
  ].request();

  statuses.forEach((permission, status) {
    if (!status.isGranted) {
      debugPrint("Permission denied: $permission");
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => NutritionCubit(GeminiApiRepository())),
      ],
      child: BlocBuilder<ThemeCubit, AppTheme>(
        builder: (context, themeState) {
      
          SizeConfig.init(context);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Nutrilens',
            theme: AppThemes.lightTheme,       
            darkTheme: AppThemes.darkTheme,    
            themeMode: themeState == AppTheme.light
                ? ThemeMode.light
                : ThemeMode.dark,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
