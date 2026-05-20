
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_storage/get_storage.dart';


import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/error_handlers/error_handler.dart';

import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/auth_security.dart';

import '../../constants/uiConstants.dart';
import '../../screens/loading_screen.dart';


part 'user_data_state.dart';

class UserDataCubit extends Cubit<UserDataState> {
  final ErrorHandlers _errorHandler = ErrorHandlers();
  final GetStorage _storage = GetStorage();
  static const int _maxLoginAttempts = 30;
  static const Duration _lockDuration = Duration(hours: 1);
  static const String _ownerExitPendingKey = 'owner_exit_pending';
  static const String _lastOwnerUserIdKey = 'last_owner_user_id';
  // List<UserModel> _allUserModelList = [];
  // final List<UserModel> _activeUserModelList = [];
  // final DBHelper dbHelper = DBHelper.instance;

  UserDataCubit() : super(const UserData(userModel: null, allUserModelList: [],activeUserModelList: [])){
    _initializeUserModelList();
  }

  Future<void> _initializeUserModelList()async{
    final List<UserModel> allUserModelList = await DBHelper.getAllUsersFromDB();
    final List<UserModel> activeUserModelList = [];
    UserModel? currentUserModel = state.userModel;

    for(UserModel data in allUserModelList){
      if(data.activeStatus){
        activeUserModelList.add(data);
      }
      if(state.userModel != null){
        if(state.userModel!.id == data.id){
          currentUserModel = data;
        }
      }
    }
    emit(UserData(userModel: currentUserModel, allUserModelList: allUserModelList, activeUserModelList: activeUserModelList));

  }
  //
  Future<void>initData()async{
    await _initializeUserModelList();
    await _handlePendingOwnerLogout();
  }

  UserModel? getSingleUser(int index){
    UserModel? userModel = state.allUserModelList.firstWhereOrNull((element) => element.id == index);
    return userModel;
  }

  Future<bool> login({
    required String userName,
    required String password,
    required UserLevel userLevel,
    required BuildContext buildContext,
  })async{
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: buildContext,
      builder: (buildCtx){
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

    final lockDuration = _getRemainingLockDuration(userName, userLevel);
    if (lockDuration != null) {
      if (buildContext.mounted) {
        Navigator.of(buildContext).pop();
      }
      _errorHandler.showErrorWithBtn(
        title: null,
        txt: "Too many failed attempts. Try again in ${_formatDuration(lockDuration)}.",
      );
      return false;
    }

    bool value = await isAuthenticated(userName,password,userLevel);
    if(value){
      _clearLoginFailureState(userName, userLevel);

      if(userLevel == UserLevel.superAdmin){
        _markOwnerSession();
        if (buildContext.mounted) {
          Navigator.of(buildContext).pop();
        }
        await _initializeUserModelList();
        return true;
      }else{
        final historySuccess = await DBHelper.loginAndLogOut(
          userModel: state.userModel!,
          isLogin : true,
        );

        _markOwnerSession();
        if (buildContext.mounted) {
          Navigator.of(buildContext).pop();
        }
        await _initializeUserModelList();
        if(!historySuccess){
          _errorHandler.showErrorWithBtn(title: null, txt: "History update is not successful");
        }
        return historySuccess;
      }

    }else{
      final failMessage = _registerFailedAttemptAndGetMessage(userName, userLevel);
      if (buildContext.mounted) {
        Navigator.of(buildContext).pop();
      }
      _errorHandler.showErrorWithBtn(title: null, txt: failMessage);
      return false;
    }

  }


  Future<bool> isAuthenticated(String userName, String password, UserLevel userLevel) async {
    UserModel? userModel;

    if (userLevel == UserLevel.superAdmin) {
      final storedSuperAdminPassword = _storage.read<String>(_superAdminPasswordKey) ??
          TxtConstants.superAdminModelData.password;
      final isUserMatched = userName == TxtConstants.superAdminModelData.userName;
      final isPasswordMatched = AuthSecurity.verifyPassword(
        storedPassword: storedSuperAdminPassword,
        inputPassword: password,
      );

      if (isUserMatched && isPasswordMatched) {
        if (!AuthSecurity.isHashed(storedSuperAdminPassword)) {
          _storage.write(_superAdminPasswordKey, AuthSecurity.hashPassword(password));
        }

        userModel = UserModel(
          id: TxtConstants.superAdminModelData.id,
          userName: TxtConstants.superAdminModelData.userName,
          password: _storage.read<String>(_superAdminPasswordKey) ?? storedSuperAdminPassword,
          userLevel: TxtConstants.superAdminModelData.userLevel,
          userCreatedTime: TxtConstants.superAdminModelData.userCreatedTime,
          userLoginTime: TxtConstants.superAdminModelData.userLoginTime,
          userLogoutTime: TxtConstants.superAdminModelData.userLogoutTime,
          activeStatus: TxtConstants.superAdminModelData.activeStatus,
          imageId: TxtConstants.superAdminModelData.imageId,
        );
      }
    } else {
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
          await DBHelper.changeUserPassword(
            userId: element.id,
            newPassword: password,
          );
          await _initializeUserModelList();
          userModel = state.activeUserModelList.firstWhereOrNull((e) => e.id == element.id) ?? element;
        } else {
          userModel = element;
        }
        break;
      }
    }

    if (userModel == null) {
      return false;
    }

    emit(UserData(
      userModel: userModel,
      allUserModelList: state.allUserModelList,
      activeUserModelList: state.activeUserModelList,
    ));
    return true;
  }

  Future<bool>createNewUser({
    required String userName,
    required String password,
    required UserLevel userLevel,
  })async{
    bool value = await DBHelper.createNewUser(userName: userName, password: password, userLevel: userLevel);
    await _initializeUserModelList();
    return value;
  }


  Future<void> clearAllData()async{
    emit(const UserData(userModel: null, allUserModelList: [], activeUserModelList: []));
  }

  Future<bool>logout()async{
    if (state.userModel == null) {
      return true;
    }

    if(state.userModel!.userLevel == UserLevel.superAdmin){
      _clearOwnerSessionMarker();
      await clearAllData();
      return true;
    }else{
      bool value = await DBHelper.loginAndLogOut(
        userModel: state.userModel!,
        isLogin : false,
      );
      if(value){
        _clearOwnerSessionMarker();
        await clearAllData();
      }
      return value;
    }
  }

  Future<void> onAppDetached() async {
    final user = state.userModel;
    if (user == null) return;
    if (!_isOwner(user.userLevel)) return;

    _storage.write(_ownerExitPendingKey, true);
    _storage.write(_lastOwnerUserIdKey, user.id);

    if (user.userLevel != UserLevel.superAdmin) {
      await DBHelper.loginAndLogOut(
        userModel: user,
        isLogin: false,
      );
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

    if (user.userLevel == UserLevel.superAdmin) {
      final hashedPassword = AuthSecurity.hashPassword(newPassword);
      _storage.write(_superAdminPasswordKey, hashedPassword);
      emit(UserData(
        userModel: UserModel(
          id: user.id,
          userName: user.userName,
          password: hashedPassword,
          userLevel: user.userLevel,
          userCreatedTime: user.userCreatedTime,
          userLoginTime: user.userLoginTime,
          userLogoutTime: user.userLogoutTime,
          activeStatus: user.activeStatus,
          imageId: user.imageId,
        ),
        allUserModelList: state.allUserModelList,
        activeUserModelList: state.activeUserModelList,
      ));
      return null;
    }

    final bool value = await DBHelper.changeUserPassword(
      userId: user.id,
      newPassword: newPassword,
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

    final targetUser = state.allUserModelList.firstWhereOrNull((e) => e.id == targetUserId);
    if (targetUser == null) {
      return "Target user not found.";
    }

    if (targetUser.userLevel == UserLevel.superAdmin) {
      return "Super admin password cannot be reset here.";
    }

    final value = await DBHelper.changeUserPassword(
      userId: targetUserId,
      newPassword: newPassword,
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

  static const String _superAdminPasswordKey = 'super_admin_password';

  bool _verifyPassword({
    required UserModel user,
    required String inputPassword,
  }) {
    if (user.userLevel == UserLevel.superAdmin) {
      final stored = _storage.read<String>(_superAdminPasswordKey) ??
          TxtConstants.superAdminModelData.password;
      return AuthSecurity.verifyPassword(
        storedPassword: stored,
        inputPassword: inputPassword,
      );
    }
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
    final int? lockUntilMs = _storage.read<int>(_lockUntilKey(userName, userLevel));
    if (lockUntilMs == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (lockUntilMs <= now) {
      _clearLoginFailureState(userName, userLevel);
      return null;
    }

    return Duration(milliseconds: lockUntilMs - now);
  }

  String _registerFailedAttemptAndGetMessage(String userName, UserLevel userLevel) {
    final countKey = _attemptCountKey(userName, userLevel);
    int failedCount = (_storage.read<int>(countKey) ?? 0) + 1;

    if (failedCount >= _maxLoginAttempts) {
      final lockUntil = DateTime.now().add(_lockDuration).millisecondsSinceEpoch;
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
    if (!_isOwner(user.userLevel)) return;
    _storage.write(_lastOwnerUserIdKey, user.id);
    _storage.remove(_ownerExitPendingKey);
  }

  void _clearOwnerSessionMarker() {
    _storage.remove(_ownerExitPendingKey);
    _storage.remove(_lastOwnerUserIdKey);
  }

  Future<void> _handlePendingOwnerLogout() async {
    final bool shouldProcess = _storage.read<bool>(_ownerExitPendingKey) ?? false;
    if (!shouldProcess) return;

    final int? ownerId = _storage.read<int>(_lastOwnerUserIdKey);
    if (ownerId == null) {
      _clearOwnerSessionMarker();
      return;
    }

    final owner = state.allUserModelList.firstWhereOrNull((e) => e.id == ownerId);
    if (owner != null && owner.userLevel == UserLevel.merchant) {
      await DBHelper.loginAndLogOut(
        userModel: owner,
        isLogin: false,
      );
    }

    _clearOwnerSessionMarker();
  }

}
