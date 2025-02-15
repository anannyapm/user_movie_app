import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:sample_project/providers/movie_provider.dart';
import 'package:sample_project/repository/movie_repository.dart';
import 'package:sample_project/services/hive_services.dart';
import 'package:sample_project/services/network_service.dart';
import 'package:sample_project/services/workmanager_services.dart';
import '../../repository/user_repository.dart';
import '../../providers/user_provider.dart';

// fvm flutter pub run build_runner build --delete-conflicting-outputs

final GetIt getIt = GetIt.instance;

void setupLocator() {
  // Register Dio
  getIt.registerLazySingleton(() => Dio());

  // Register Repositories
  getIt.registerLazySingleton(() => UserRepository());
  getIt.registerLazySingleton(() => MovieRepository());

  // Register Providers
  getIt.registerFactory(() => UserProvider(getIt<UserRepository>()));
  getIt.registerFactory(() => MovieProvider(getIt<MovieRepository>()));

  //Services
  getIt.registerLazySingleton<HiveService>(() => HiveService());
  getIt.registerLazySingleton<BackgroundFetchService>(
      () => BackgroundFetchService());
  getIt.registerLazySingleton<NetworkService>(() => NetworkService());
}
