import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

// Сервис для проверки подключения к сети
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  Future<bool> isConnected() async {
    try {
      final List<ConnectivityResult> connectivityResults = await Connectivity()
          .checkConnectivity();

      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      return await _hasInternetConnection();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      try {
        final result = await InternetAddress.lookup(
          'firebase.google.com',
        ).timeout(const Duration(seconds: 5));

        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        return false;
      }
    }
  }

  Future<String> getConnectionStatus() async {
    try {
      final List<ConnectivityResult> connectivityResults = await Connectivity()
          .checkConnectivity();

      if (connectivityResults.isEmpty) {
        return 'Статус подключения неизвестен';
      }

      final primaryResult = connectivityResults.firstWhere(
        (result) => result != ConnectivityResult.none,
        orElse: () => ConnectivityResult.none,
      );

      switch (primaryResult) {
        case ConnectivityResult.wifi:
          return 'Подключено через Wi-Fi';
        case ConnectivityResult.mobile:
          return 'Подключено через мобильную сеть';
        case ConnectivityResult.ethernet:
          return 'Подключено через Ethernet';
        case ConnectivityResult.bluetooth:
          return 'Подключено через Bluetooth';
        case ConnectivityResult.none:
          return 'Нет подключения к интернету';
        case ConnectivityResult.other:
          return 'Подключено через другую сеть';
        default:
          return 'Статус подключения неизвестен';
      }
    } catch (e) {
      return 'Статус подключения неизвестен';
    }
  }

  Stream<List<ConnectivityResult>> get connectivityStream =>
      Connectivity().onConnectivityChanged;
}
