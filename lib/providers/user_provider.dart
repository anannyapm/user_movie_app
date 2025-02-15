import 'package:flutter/material.dart';
import 'package:sample_project/core/models/user_models.dart';
import 'package:sample_project/repository/user_repository.dart';
import 'dart:async';
import 'dart:developer' as developer;

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;

  UserProvider(this._userRepository) {
    _initStream();
  }

  ///variables
  List<UserModel> _filteredUsers = [];
  String _searchQuery = '';
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Timer? _debounce;
  
  List<UserModel> _users = [];
  List<UserModel> get users => _filteredUsers.isEmpty ? _users : _filteredUsers;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<List<UserModel>>? _userStreamSubscription;

  ///functions

  //initialize stream subscription
  void _initStream() {
    _userStreamSubscription = _userRepository.userStream.listen(
      (users) {
        _users = users;
        _filteredUsers = [];
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to fetch users: $error';
        notifyListeners();
      },
    );
  }

  //fetch user list
  Future<void> fetchUsers() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _userRepository.fetchUsers();
    } catch (e) {
      _errorMessage = 'Error fetching users: $e';
      developer.log('Error fetching users: $e', name: 'UserProvider');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //add user
  Future<void> addUser(String name, String job) async {
    UserModel newUser = UserModel(
      firstName: name,
      lastName: '',
      job: job,
      email: '',
      avatar: '',
      id: null,
    );

    try {
      await _userRepository.addUser(newUser);
    } catch (e) {
      _errorMessage = 'Error adding user: $e';
      developer.log('Error adding user: $e', name: 'UserProvider');
    }
  }

  //sync users that are offline
  Future<void> syncOfflineUsers() async {
    try {
      await _userRepository.syncOfflineUsers();

      await fetchUsers();
    } catch (e) {
      _errorMessage = 'Error syncing users: $e';
      developer.log('Error syncing users: $e', name: 'UserProvider');
    }
  }

  //search users
  void searchUsers(String query) {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredUsers.clear();
      } else {
        _filteredUsers = _users.where((user) {
          final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
          final job = user.job?.toLowerCase() ?? '';
          return fullName.contains(_searchQuery) || job.contains(_searchQuery);
        }).toList();
      }
      notifyListeners();
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredUsers.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _userStreamSubscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }
}
