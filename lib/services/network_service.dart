import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  Future<bool> isConnected() async {
    List<ConnectivityResult> connectivityResult =
        await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
}
