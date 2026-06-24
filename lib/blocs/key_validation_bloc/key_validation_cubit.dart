import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:pos_mobile/services/key_validation_service.dart';
import 'package:pos_mobile/utils/debug_print.dart';

part 'key_validation_state.dart';

class KeyValidationCubit extends Cubit<KeyValidationState> {
  final GetStorage _storage = GetStorage();

  static const String _keyValidationKey = 'app_key_validated';
  static const String _activatedKeyKey = 'activated_key';
  static const String _deviceIdKey = 'device_id';
  static const String _firstTimeSetupKey = 'first_time_setup';
  static const String _installDateKey = 'install_date';

  final String appEnv;

  KeyValidationCubit({required this.appEnv})
    : super(const KeyValidationState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkInstallDate();
    await _checkIfAlreadyValidated();
    if (state.isKeyValidated) {
      verifyKeyWithServer();
    }
    _checkExpiration();
  }

  Future<void> _checkInstallDate() async {
    if (_storage.read(_installDateKey) == null) {
      await _storage.write(_installDateKey, DateTime.now().toIso8601String());
    }
  }

  void _checkExpiration() {
    if (appEnv != 'production') {
      final installDateStr = _storage.read(_installDateKey);
      if (installDateStr != null) {
        final installDate = DateTime.parse(installDateStr);
        if (DateTime.now().difference(installDate).inDays >= 365) {
          emit(
            state.copyWith(
              isAppLocked: true,
              lockErrorMessage:
                  'This is not a production app, the app will be locked (Trial period expired).',
            ),
          );
        }
      }
    }
  }

  /// Check if the app key is already validated on this device
  Future<void> _checkIfAlreadyValidated() async {
    try {
      if (appEnv != 'production') {
        final isFirstTime = _storage.read(_firstTimeSetupKey) ?? true;
        emit(
          state.copyWith(
            isKeyValidated: true,
            isFirstTimeSetup: isFirstTime,
          ),
        );
        return;
      }

      final isValidated = _storage.read(_keyValidationKey) ?? false;
      final isFirstTime = _storage.read(_firstTimeSetupKey) ?? true;

      if (isValidated) {
        emit(
          state.copyWith(isKeyValidated: true, isFirstTimeSetup: isFirstTime),
        );
      } else {
        emit(state.copyWith(isFirstTimeSetup: isFirstTime));
      }
    } catch (e) {
      cusDebugPrint('Error checking key validation status: $e');
    }
  }

  /// Verify the stored key with the server to check if it's still valid or if duplicates exist
  Future<void> verifyKeyWithServer() async {
    final key = _storage.read(_activatedKeyKey) as String?;
    if (key == null || key.isEmpty) {
      return;
    }

    try {
      final deviceId = await _getDeviceId();
      cusDebugPrint('Periodic verification for key: $key, deviceId: $deviceId');

      final result = await KeyValidationService.validateKeyDetails(
        key: key.trim(),
        deviceId: deviceId,
      );

      if (result['valid'] == true) {
        // Still perfectly valid!
        emit(
          state.copyWith(
            isAppLocked: false,
            lockErrorMessage: null,
            isKeyValidated: true,
          ),
        );
      } else {
        // Invalid or duplicated!
        final message = result['message'] as String? ?? 'Invalid license key.';
        final isDuplicate =
            result['error_type'] == 'duplicate_device' ||
            message.contains('Duplicate');

        if (isDuplicate) {
          emit(
            state.copyWith(
              isKeyValidated:
                  true, // It is a validated key, but the app is locked!
              isAppLocked: true,
              lockErrorMessage: message,
            ),
          );
        } else {
          // If the key is totally invalid (e.g. deleted or deactivated by admin), clear storage so they have to register again
          await _storage.remove(_keyValidationKey);
          await _storage.remove(_activatedKeyKey);
          emit(
            state.copyWith(
              isKeyValidated: false,
              isAppLocked: false,
              errorMessage:
                  'License key is no longer valid. Please reactivate.',
            ),
          );
        }
      }
    } catch (e) {
      // If there is an internet/network error, we shouldn't block the user (offline support), so do nothing
      cusDebugPrint(
        'Failed to verify key with server (network error / offline): $e',
      );
    }
  }

  /// Get or create unique device identifier
  Future<String> _getDeviceId() async {
    try {
      // Check if device ID already exists
      String? storedDeviceId = _storage.read(_deviceIdKey);

      if (storedDeviceId != null && storedDeviceId.isNotEmpty) {
        return storedDeviceId;
      }

      // Create new device ID using UUID + platform identifier
      final uuid = const Uuid().v4();
      final platformId = Platform.isAndroid ? 'android' : 'ios';
      final deviceId = '${platformId}_$uuid';

      // Store it for future use
      await _storage.write(_deviceIdKey, deviceId);

      cusDebugPrint('Created new device ID: $deviceId');
      return deviceId;
    } catch (e) {
      cusDebugPrint('Error getting device ID: $e');
    }
    return 'unknown_device';
  }

  /// Validate the user's key input
  Future<void> validateKey(String keyInput) async {
    if (appEnv != 'production') return;

    if (keyInput.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Please enter a valid key',
          isLoading: false,
        ),
      );
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      // Get device ID
      final deviceId = await _getDeviceId();
      cusDebugPrint('Device ID for key validation: $deviceId');

      // Validate key details with backend
      final result = await KeyValidationService.validateKeyDetails(
        key: keyInput.trim(),
        deviceId: deviceId,
      );

      if (result['valid'] == true) {
        // Store validation status and key
        await _storage.write(_keyValidationKey, true);
        await _storage.write(_activatedKeyKey, keyInput.trim());

        // Mark first time setup as complete (for future launches)
        final isFirstTime = state.isFirstTimeSetup;

        emit(
          state.copyWith(
            isKeyValidated: true,
            isAppLocked: false,
            lockErrorMessage: null,
            isLoading: false,
            errorMessage: null,
            isFirstTimeSetup: isFirstTime,
          ),
        );
      } else {
        final message =
            result['message'] as String? ??
            'Invalid key or already used. Please try again.';
        final isDuplicate =
            result['error_type'] == 'duplicate_device' ||
            message.contains('Duplicate');

        if (isDuplicate) {
          // Store it so that the application knows it is registered but locked
          await _storage.write(_keyValidationKey, true);
          await _storage.write(_activatedKeyKey, keyInput.trim());

          emit(
            state.copyWith(
              isKeyValidated: true,
              isAppLocked: true,
              lockErrorMessage: message,
              isLoading: false,
              errorMessage: null,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isKeyValidated: false,
              isAppLocked: false,
              isLoading: false,
              errorMessage: message,
              validationAttempts: (state.validationAttempts ?? 0) + 1,
            ),
          );
        }
      }
    } catch (e) {
      cusDebugPrint('Error during key validation: $e');
      emit(
        state.copyWith(
          isKeyValidated: false,
          isLoading: false,
          errorMessage:
              'Error validating key. Please check your internet connection.',
        ),
      );
    }
  }

  /// Reset key validation (for logout or re-validation)
  Future<void> resetKeyValidation() async {
    try {
      await _storage.remove(_keyValidationKey);
      await _storage.remove(_activatedKeyKey);
      emit(const KeyValidationState());
    } catch (e) {
      cusDebugPrint('Error resetting key validation: $e');
    }
  }

  /// Mark first time setup as complete
  Future<void> completeFirstTimeSetup() async {
    try {
      await _storage.write(_firstTimeSetupKey, false);
      emit(state.copyWith(isFirstTimeSetup: false));
    } catch (e) {
      cusDebugPrint('Error marking first time setup as complete: $e');
    }
  }

  /// Check if device already has a validated key
  Future<bool> isDeviceAlreadyValidated() async {
    try {
      final deviceId = await _getDeviceId();
      return await KeyValidationService.checkDeviceKeyStatus(
        deviceId: deviceId,
      );
    } catch (e) {
      cusDebugPrint('Error checking device validation status: $e');
      return false;
    }
  }
}
