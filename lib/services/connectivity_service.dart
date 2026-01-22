import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker();
  
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;
  
  Future<ConnectivityResult> get connectivityStatus async {
    return await _connectivity.checkConnectivity();
  }
  
  Future<bool> get isConnected async {
    final connectivityResult = await connectivityStatus;
    
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    
    try {
      return await _connectionChecker.hasConnection;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> isConnectionStable({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      for (int i = 0; i < 3; i++) {
        if (!await isConnected) return false;
        await Future.delayed(Duration(milliseconds: 500));
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}