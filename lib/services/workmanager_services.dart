import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sample_project/repository/user_repository.dart';
import 'package:background_fetch/background_fetch.dart';
import 'dart:developer';

class BackgroundFetchService {
  // Initialize BackgroundFetch and set up periodic tasks
  static void registerBackgroundFetch() {
    // Configuration for BackgroundFetch
    BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY,
      ),
      _onBackgroundFetch,
    ).then((status) {
      log("[BackgroundFetch] Configured status: $status");
    }).catchError((e) {
      log("[BackgroundFetch] Configuration error: $e");
    });

    Connectivity().onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        log("Device is online. Triggering sync...");
        _onBackgroundFetch("connectivity");
      } else {
        log("Device is offline. Sync postponed...");
      }
    });
  }

  // Callback for background fetch events
  @pragma('vm:entry-point')
  static void _onBackgroundFetch(String taskId) async {
    log("[BackgroundFetch] Task executed: $taskId");

    if (taskId == "flutter_background_fetch" || taskId == "connectivity") {
      log("Syncing offline users...");
      final userRepository = UserRepository();
      await userRepository.syncOfflineUsers();
      await userRepository.fetchUsers();
    }

    BackgroundFetch.finish(taskId);
  }
}
