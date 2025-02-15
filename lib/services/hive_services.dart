import 'package:hive_flutter/hive_flutter.dart';
import 'package:sample_project/core/models/user_models.dart';

class HiveService {
  late Box<UserModel> _dbstorage;

  // Initialize Hive storage
  Future<void> initStorage() async {
    if (!Hive.isBoxOpen('userBox')) {
      _dbstorage = await Hive.openBox<UserModel>('userBox');
    } else {
      _dbstorage = Hive.box<UserModel>('userBox');
    }
  }

  // Add a user to Hive
  Future<void> addUser(UserModel user) async {
    initStorage();
    await _dbstorage.add(user);
  }

  // Add multiple users to Hive
  Future<void> addAllUsers(List<UserModel> users) async {
    initStorage();
    await _dbstorage.addAll(users);
  }

  // Get all users from Hive
  Future<List<UserModel>> getAllUsers() async {
    initStorage();

    return _dbstorage.values.toList();
  }

  // Get offline users (users without an ID)
  Future<List<UserModel>> getOfflineUsers() async {
    initStorage();

    return _dbstorage.values.where((user) => user.id == null).toList();
  }

  // Update a user's ID
  Future<void> updateUserId(UserModel user) async {
    initStorage();

    var key = _dbstorage.keys
        .firstWhere((k) => _dbstorage.get(k) == user, orElse: () => null);
    if (key != null) {
      await _dbstorage.put(key, user);
    }
  }

  // Clear all users from Hive
  Future<void> clearAllUsers() async {
    initStorage();

    await _dbstorage.clear();
  }
}
