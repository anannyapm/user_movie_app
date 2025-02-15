import 'dart:async';
import 'package:dio/dio.dart';
import 'package:sample_project/core/di/locator.dart';
import 'package:sample_project/core/models/user_models.dart';
import 'package:sample_project/services/hive_services.dart';
import 'package:sample_project/services/network_service.dart';
import 'dart:developer' as developer;

class UserRepository {
  final Dio _dio = getIt<Dio>();
  final HiveService _hiveService = getIt<HiveService>();
  final NetworkService _networkService = getIt<NetworkService>();

  final StreamController<List<UserModel>> _userStreamController =
      StreamController<List<UserModel>>.broadcast();
  Stream<List<UserModel>> get userStream => _userStreamController.stream;

  static const String _userApiUrl = 'https://reqres.in/api/users';

  List<UserModel> _allUsers = [];
  int _currentPage = 1;
  bool _isFetching = false; // To handle redundant API calls

  Future<List<UserModel>> fetchUsers() async {
    if (_isFetching) return _allUsers;

    _isFetching = true;
    try {
      bool isOnline = await _networkService.isConnected();

      if (isOnline) {
        final response = await _dio.get('$_userApiUrl?page=$_currentPage');
        List<dynamic> usersJson = response.data['data'];

        List<UserModel> apiUsers =
            usersJson.map((json) => UserModel.fromJson(json)).toList();

        if (_currentPage == 1) {
          _allUsers = apiUsers;
        } else {
          _allUsers.addAll(apiUsers);
        }

        await syncOfflineUsers();

        List<UserModel> hiveUsers = await _hiveService.getAllUsers();
        _allUsers = _combineUsers(hiveUsers, _allUsers);

        _userStreamController.add(_allUsers);

        _currentPage++;
      } else {
        if (_allUsers.isEmpty) {
          _allUsers = await _hiveService.getAllUsers();
        } else {
          List<UserModel> hiveUsers = await _hiveService.getAllUsers();
          _allUsers = _combineUsers(hiveUsers, _allUsers);
        }
        _userStreamController.add(_allUsers);
      }
      return _allUsers;
    } catch (e) {
      developer.log('Error fetching users: $e');
      return [];
    } finally {
      _isFetching = false;
    }
  }

  Future<List<UserModel>> fetchUsersWithInitialPage() async {
    developer.log('Fetching users', name: 'UserRepository');
    developer.log('Is fetching: $_isFetching', name: 'UserRepository');
    _currentPage = 1;
    if (_isFetching) return _allUsers;

    _isFetching = true;

    try {
      bool isOnline = await _networkService.isConnected();
      developer.log('Is online: $isOnline', name: 'UserRepository');

      if (isOnline) {
        final response = await _dio.get('$_userApiUrl?page=1');
        List<dynamic> usersJson = response.data['data'];

        List<UserModel> apiUsers =
            usersJson.map((json) => UserModel.fromJson(json)).toList();

        if (_currentPage == 1) {
          _allUsers = apiUsers;
        } else {
          _allUsers.addAll(apiUsers);
        }

        await syncOfflineUsers();

        List<UserModel> hiveUsers = await _hiveService.getAllUsers();
        _allUsers = _combineUsers(hiveUsers, _allUsers);

        _userStreamController.add(_allUsers);

        _currentPage++;
      } else {
        if (_allUsers.isEmpty) {
          _allUsers = await _hiveService.getAllUsers();
        } else {
          List<UserModel> hiveUsers = await _hiveService.getAllUsers();
          _allUsers = _combineUsers(hiveUsers, _allUsers);
        }
        _userStreamController.add(_allUsers);
      }
      return _allUsers;
    } catch (e) {
      developer.log('Error fetching users: $e');
      return [];
    } finally {
      _isFetching = false;
    }
  }

  Future<void> addUser(UserModel user) async {
    bool isOnline = await _networkService.isConnected();

    if (isOnline) {
      try {
        final response = await _dio.post(_userApiUrl, data: user.toJson());
        user.id = int.tryParse(response.data['id'].toString());
        developer.log('Done adding user online: $response');

        _allUsers.insert(0, user);
        await _hiveService.addUser(user);
        _userStreamController.add(_allUsers);
      } catch (e) {
        developer.log('Error adding user online: $e');
      }
    } else {
      await _hiveService.addUser(user);
      _allUsers.insert(0, user);
      _userStreamController.add(_allUsers);
    }
  }

  Future<void> syncOfflineUsers() async {
    bool isOnline = await _networkService.isConnected();
    if (!isOnline) return;

    List<UserModel> offlineUsers = await _hiveService.getOfflineUsers();

    for (var user in offlineUsers) {
      try {
        final response = await _dio.post(_userApiUrl, data: user.toJson());
        developer.log('Done uploading user: $response');

        user.id = int.tryParse(response.data['id'].toString());
        await _hiveService.updateUserId(user);
      } catch (e) {
        developer.log('Error syncing user: $e');
      }
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    List<UserModel> hiveUsers = await _hiveService.getAllUsers();

    _allUsers = await fetchUsers();
    _allUsers = _combineUsers(hiveUsers, _allUsers);

    _userStreamController.add(_allUsers);

    return _allUsers;
  }

  List<UserModel> _combineUsers(
      List<UserModel> hiveUsers, List<UserModel> apiUsers) {
    Map<int, UserModel> combinedUsers = {};
    List<UserModel> nullIdUsers = [];

    for (var user in hiveUsers) {
      if (user.id == null) {
        nullIdUsers.add(user);
      } else if (!combinedUsers.containsKey(user.id)) {
        combinedUsers[user.id!] = user;
      }
    }

    for (var user in apiUsers) {
      if (user.id == null) {
        nullIdUsers.add(user);
      } else if (!combinedUsers.containsKey(user.id)) {
        combinedUsers[user.id!] = user;
      }
    }

    return combinedUsers.values.toList()..addAll(nullIdUsers);
  }

  void dispose() {
    _userStreamController.close();
  }
}
