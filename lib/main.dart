import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sample_project/core/models/user_models.dart';
import 'package:sample_project/providers/movie_provider.dart';
import 'package:sample_project/services/hive_services.dart';
import 'package:sample_project/services/workmanager_services.dart';
import 'package:sample_project/ui/views/user_list_view.dart';
import 'core/di/locator.dart';
import 'providers/user_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(UserModelAdapter());
  await getIt<HiveService>().initStorage();

  BackgroundFetchService.registerBackgroundFetch();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<UserProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<MovieProvider>()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UserListScreen(),
      ),
    );
  }
}
