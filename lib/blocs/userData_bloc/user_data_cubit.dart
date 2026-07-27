import 'package:pos_mobile/services/pos_repository.dart';
import 'package:pos_mobile/services/network_environment.dart';
import 'package:pos_mobile/services/pos_api_client.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';

import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/error_handlers/error_handler.dart';

import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/auth_security.dart';
import 'package:pos_mobile/utils/debug_print.dart';

import '../../constants/uiConstants.dart';
import '../../screens/loading_screen.dart';

part 'user_data_state.dart';

class UserDataCubit extends Cubit<UserDataState> {
  final ErrorHandlers _errorHandler = ErrorHandlers();
  final GetStorage _storage = GetStorage();
  static const int _maxLoginAttempts = 30;
  static const Duration _lockDuration = Duration(hours: 1);
  static const String _ownerExitPendingKey = 'owner_exit_pending';
  static const String _lastUserIdKey = 'last_user_id';
  static const String _lastOwnerUserIdKey = 'last_owner_user_id';
  // List<UserModel> _allUserModelList = [];
  // final List<UserModel> _activeUserModelList = [];

  UserDataCubit()
    : super(
        const UserData(
          userModel: null,
          allUserModelList: [],
          activeUserModelList: [],
          isInitialized: false,
        ),
      ) {
    _initializeUserModelList();
  }

  Future<void> _initializeUserModelList({
    bool preserveCurrentUser = true,
  }) async {
    try {
      // The user list is protected by the backend. Before login, only use
      // the public shop-status endpoint to decide whether setup is needed.
      final unauthenticatedBackend =
          NetworkConfiguration.usesBackend &&
          PosRepository.instance.api.token == null;
      if (unauthenticatedBackend) {
        var merchantExists = false;
        var statusChecked = false;
        String? statusError;
        try {
          merchantExists = await PosRepository.instance.merchantExists();
          statusChecked = true;
        } catch (error) {
          statusError = 'Unable to check merchant setup status.';
          cusDebugPrint('Failed to check backend shop status: $error');
        }
        emit(
          UserData(
            userModel: null,
            allUserModelList: const [],
            activeUserModelList: const [],
            isInitialized: true,
            merchantExists: merchantExists,
            setupStatusError: statusChecked ? null : statusError,
          ),
        );
        return;
      }

      final allUserModelList = await PosRepository.instance.readWithMode(
        local: () => LocalPosRepository.getAllUsersFromDB(),
        remote: () async => (await PosRepository.instance.fetchUsers())
            .map(_userFromBackend)
            .toList(),
      );
      final List<UserModel> activeUserModelList = [];
      UserModel? currentUserModel = preserveCurrentUser
          ? state.userModel
          : null;
      final persistedUserId =
          _storage.read<int>(_lastUserIdKey) ??
          _storage.read<int>(_lastOwnerUserIdKey);
      if (currentUserModel == null && persistedUserId != null) {
        currentUserModel = allUserModelList.firstWhereOrNull(
          (user) => user.id == persistedUserId && user.activeStatus,
        );
      }

      for (final data in allUserModelList) {
        if (data.activeStatus) {
          activeUserModelList.add(data);
        }
        if (currentUserModel != null && currentUserModel.id == data.id) {
          currentUserModel = data;
        }
      }

      emit(
        UserData(
          userModel: currentUserModel,
          allUserModelList: allUserModelList,
          activeUserModelList: activeUserModelList,
          isInitialized: true,
          merchantExists: allUserModelList.any(
            (user) => user.userLevel == UserLevel.merchant,
          ),
        ),
      );
    } catch (e) {
      cusDebugPrint('Failed to initialize users: $e');
      var merchantExists = false;
      if (NetworkConfiguration.usesBackend) {
        try {
          merchantExists = await PosRepository.instance.merchantExists();
        } catch (statusError) {
          cusDebugPrint('Failed to check backend shop status: $statusError');
        }
      }
      emit(
        UserData(
          userModel: null,
          allUserModelList: [],
          activeUserModelList: [],
          isInitialized: true,
          merchantExists: merchantExists,
        ),
      );
    }
  }

  UserModel _userFromBackend(Map<String, dynamic> user) {
    final role = switch (user['role']) {
      'owner' => UserLevel.merchant,
      'superAdmin' => UserLevel.superAdmin,
      _ => UserLevel.staff,
    };
    return UserModel(
      id: user['id'] as int,
      userName: user['username'] as String,
      password: '',
      userLevel: role,
      userCreatedTime: DateTime.now(),
      userLoginTime: null,
      userLogoutTime: null,
      activeStatus: user['active'] == true,
      imageId: null,
    );
  }

  //
  Future<void> initData() async {
    await _initializeUserModelList();
    await _handlePendingOwnerLogout();
  }

  UserModel? getSingleUser(int index) {
    UserModel? userModel = state.allUserModelList.firstWhereOrNull(
      (element) => element.id == index,
    );
    return userModel;
  }

  Future<bool> login({
    required String userName,
    required String password,
    required UserLevel userLevel,
    required BuildContext buildContext,
  }) async {
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: buildContext,
      builder: (buildCtx) {
        return const LoadingScreen(
          txt: "Loading ...",
          widget: SpinKitCircle(
            color: Colors.grey,
            size: UIConstants.bigLoadingIconSize,
          ),
          clr: Colors.black,
        );
      },
    );

    try {
      final lockDuration = _getRemainingLockDuration(userName, userLevel);
      if (lockDuration != null) {
        if (buildContext.mounted) {
          Navigator.of(buildContext).pop();
        }
        _errorHandler.showErrorWithBtn(
          title: null,
          txt:
              "Too many failed attempts. Try again in ${_formatDuration(lockDuration)}.",
        );
        return false;
      }

      final bool value = await isAuthenticated(userName, password, userLevel);
      if (value) {
        _clearLoginFailureState(userName, userLevel);

        final historySuccess = NetworkConfiguration.usesBackend
            ? true
            : await LocalPosRepository.loginAndLogOut(
                userModel: state.userModel!,
                isLogin: true,
              );

        _markOwnerSession();
        if (buildContext.mounted) {
          Navigator.of(buildContext).pop();
        }
        await _initializeUserModelList();
        if (!historySuccess) {
          _errorHandler.showErrorWithBtn(
            title: null,
            txt: "History update is not successful",
          );
        }
        return historySuccess;
      }

      final failMessage = _registerFailedAttemptAndGetMessage(
        userName,
        userLevel,
      );
      if (buildContext.mounted) {
        Navigator.of(buildContext).pop();
      }
      _errorHandler.showErrorWithBtn(title: null, txt: failMessage);
      return false;
    } catch (e) {
      if (buildContext.mounted) {
        Navigator.of(buildContext).pop();
      }
      cusDebugPrint('Login failed: $e');
      _errorHandler.showErrorWithBtn(
        title: null,
        txt: "Login failed. Please try again.",
      );
      return false;
    }
  }

  Future<bool> isAuthenticated(
    String userName,
    String password,
    UserLevel userLevel,
  ) async {
    if (NetworkConfiguration.usesBackend) {
      try {
        final result = await PosRepository.instance.authenticate(
          username: userName,
          password: password,
        );
        final user = _userFromBackend(
          Map<String, dynamic>.from(result['user'] as Map),
        );
        emit(
          UserData(
            userModel: user,
            allUserModelList: state.allUserModelList,
            activeUserModelList: state.activeUserModelList,
            isInitialized: true,
            merchantExists: state.merchantExists,
          ),
        );
        return true;
      } on PosApiException catch (error) {
        cusDebugPrint('Backend authentication failed: $error');
        return false;
      }
    }
    UserModel? userModel;

    for (final element in state.activeUserModelList) {
      if (element.userName != userName || element.userLevel != userLevel) {
        continue;
      }

      final isMatched = AuthSecurity.verifyPassword(
        storedPassword: element.password,
        inputPassword: password,
      );

      if (!isMatched) {
        continue;
      }

      if (!AuthSecurity.isHashed(element.password)) {
        if (NetworkConfiguration.usesBackend) {
          await PosRepository.instance.updateUserPassword(
            userId: element.id,
            password: password,
          );
        } else {
          await LocalPosRepository.changeUserPassword(
            userId: element.id,
            newPassword: password,
          );
        }
        await _initializeUserModelList();
        userModel =
            state.activeUserModelList.firstWhereOrNull(
              (e) => e.id == element.id,
            ) ??
            element;
      } else {
        userModel = element;
      }
      break;
    }

    if (userModel == null) {
      return false;
    }

    emit(
      UserData(
        userModel: userModel,
        allUserModelList: state.allUserModelList,
        activeUserModelList: state.activeUserModelList,
        isInitialized: state.isInitialized,
      ),
    );
    return true;
  }

  Future<bool> createNewUser({
    required String userName,
    required String password,
    required UserLevel userLevel,
  }) async {
    final value = await PosRepository.instance.writeWithMode(
      remote: () => PosRepository.instance.createUser(
        username: userName,
        password: password,
        role: userLevel == UserLevel.merchant ? 'owner' : 'staff',
      ),
      local: () => LocalPosRepository.createNewUser(
        userName: userName,
        password: password,
        userLevel: userLevel,
      ),
    );
    await _initializeUserModelList();
    return value;
  }

  Future<void> clearAllData() async {
    emit(
      const UserData(
        userModel: null,
        allUserModelList: [],
        activeUserModelList: [],
        isInitialized: false,
      ),
    );
  }

  Future<bool> logout() async {
    if (state.userModel == null) {
      return true;
    }

    final bool value;
    if (NetworkConfiguration.usesBackend) {
      await PosRepository.instance.logout();
      value = true;
    } else {
      value = await LocalPosRepository.loginAndLogOut(
        userModel: state.userModel!,
        isLogin: false,
      );
    }
    if (value) {
      _clearOwnerSessionMarker();
      await _initializeUserModelList(preserveCurrentUser: false);
    }
    return value;
  }

  Future<void> onAppDetached() async {
    final user = state.userModel;
    if (user == null) return;
    if (!_isOwner(user.userLevel)) return;

    _storage.write(_ownerExitPendingKey, true);
    _storage.write(_lastUserIdKey, user.id);
    _storage.write(_lastOwnerUserIdKey, user.id);

    if (!NetworkConfiguration.usesBackend) {
      await LocalPosRepository.loginAndLogOut(userModel: user, isLogin: false);
    }

    await clearAllData();
  }

  Future<String?> changeOwnerPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = state.userModel;
    if (user == null) {
      return "No active user.";
    }

    if (!_isOwner(user.userLevel)) {
      return "Only owner can change owner password.";
    }

    if (newPassword.trim().length < 6) {
      return "New password must be at least 6 characters.";
    }

    if (newPassword != confirmPassword) {
      return "New password and confirm password do not match.";
    }

    if (!_verifyPassword(user: user, inputPassword: currentPassword)) {
      return "Current password is incorrect.";
    }

    final bool value = await PosRepository.instance.writeWithMode(
      remote: () => PosRepository.instance.updateUserPassword(
        userId: user.id,
        password: newPassword,
      ),
      local: () => LocalPosRepository.changeUserPassword(
        userId: user.id,
        newPassword: newPassword,
      ),
    );

    if (!value) {
      return "Unable to update password. Please try again.";
    }

    await _initializeUserModelList();
    return null;
  }

  Future<String?> resetUserPasswordByOwner({
    required int targetUserId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final owner = state.userModel;
    if (owner == null) {
      return "No active user.";
    }

    if (!_isOwner(owner.userLevel)) {
      return "Only owner can reset other account passwords.";
    }

    if (newPassword.trim().length < 6) {
      return "New password must be at least 6 characters.";
    }

    if (newPassword != confirmPassword) {
      return "New password and confirm password do not match.";
    }

    final targetUser = state.allUserModelList.firstWhereOrNull(
      (e) => e.id == targetUserId,
    );
    if (targetUser == null) {
      return "Target user not found.";
    }

    if (targetUser.userLevel == UserLevel.superAdmin) {
      return "Super admin password cannot be reset here.";
    }

    final value = await PosRepository.instance.writeWithMode(
      remote: () => PosRepository.instance.updateUserPassword(
        userId: targetUserId,
        password: newPassword,
      ),
      local: () => LocalPosRepository.changeUserPassword(
        userId: targetUserId,
        newPassword: newPassword,
      ),
    );

    if (!value) {
      return "Unable to reset password. Please try again.";
    }

    await _initializeUserModelList();
    return null;
  }

  bool _isOwner(UserLevel userLevel) {
    return userLevel == UserLevel.merchant || userLevel == UserLevel.superAdmin;
  }

  bool _verifyPassword({
    required UserModel user,
    required String inputPassword,
  }) {
    return AuthSecurity.verifyPassword(
      storedPassword: user.password,
      inputPassword: inputPassword,
    );
  }

  String _attemptCountKey(String userName, UserLevel level) =>
      'login_attempt_count_${level.name}_${userName.toLowerCase()}';

  String _lockUntilKey(String userName, UserLevel level) =>
      'login_lock_until_${level.name}_${userName.toLowerCase()}';

  Duration? _getRemainingLockDuration(String userName, UserLevel userLevel) {
    final int? lockUntilMs = _storage.read<int>(
      _lockUntilKey(userName, userLevel),
    );
    if (lockUntilMs == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (lockUntilMs <= now) {
      _clearLoginFailureState(userName, userLevel);
      return null;
    }

    return Duration(milliseconds: lockUntilMs - now);
  }

  String _registerFailedAttemptAndGetMessage(
    String userName,
    UserLevel userLevel,
  ) {
    final countKey = _attemptCountKey(userName, userLevel);
    int failedCount = (_storage.read<int>(countKey) ?? 0) + 1;

    if (failedCount >= _maxLoginAttempts) {
      final lockUntil = DateTime.now()
          .add(_lockDuration)
          .millisecondsSinceEpoch;
      _storage.write(_lockUntilKey(userName, userLevel), lockUntil);
      _storage.write(countKey, 0);
      return "Too many failed attempts. Please wait 1 hour before trying again.";
    }

    _storage.write(countKey, failedCount);
    return "Login failed. Please try again. ($failedCount/$_maxLoginAttempts attempts)";
  }

  void _clearLoginFailureState(String userName, UserLevel userLevel) {
    _storage.remove(_attemptCountKey(userName, userLevel));
    _storage.remove(_lockUntilKey(userName, userLevel));
  }

  String _formatDuration(Duration duration) {
    final int totalMinutes = duration.inMinutes;
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void _markOwnerSession() {
    final user = state.userModel;
    if (user == null) return;
    _storage.write(_lastUserIdKey, user.id);
    if (!_isOwner(user.userLevel)) return;
    _storage.write(_lastOwnerUserIdKey, user.id);
    _storage.remove(_ownerExitPendingKey);
  }

  void _clearOwnerSessionMarker() {
    _storage.remove(_ownerExitPendingKey);
    _storage.remove(_lastUserIdKey);
    _storage.remove(_lastOwnerUserIdKey);
  }

  Future<void> _handlePendingOwnerLogout() async {
    final bool shouldProcess =
        _storage.read<bool>(_ownerExitPendingKey) ?? false;
    if (!shouldProcess) return;

    final int? ownerId = _storage.read<int>(_lastOwnerUserIdKey);
    if (ownerId == null) {
      _clearOwnerSessionMarker();
      return;
    }

    final owner = state.allUserModelList.firstWhereOrNull(
      (e) => e.id == ownerId,
    );
    if (owner != null && owner.userLevel == UserLevel.merchant) {
      if (!NetworkConfiguration.usesBackend) {
        await LocalPosRepository.loginAndLogOut(
          userModel: owner,
          isLogin: false,
        );
      }
    }

    _clearOwnerSessionMarker();
  }
}
