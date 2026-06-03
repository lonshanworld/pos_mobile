part of 'key_validation_cubit.dart';

@immutable
class KeyValidationState {
  final bool isKeyValidated;
  final bool isLoading;
  final String? errorMessage;
  final int? validationAttempts;
  final bool isFirstTimeSetup;
  final bool isAppLocked;
  final String? lockErrorMessage;

  const KeyValidationState({
    this.isKeyValidated = false,
    this.isLoading = false,
    this.errorMessage,
    this.validationAttempts = 0,
    this.isFirstTimeSetup = true,
    this.isAppLocked = false,
    this.lockErrorMessage,
  });

  KeyValidationState copyWith({
    bool? isKeyValidated,
    bool? isLoading,
    String? errorMessage,
    int? validationAttempts,
    bool? isFirstTimeSetup,
    bool? isAppLocked,
    String? lockErrorMessage,
  }) {
    return KeyValidationState(
      isKeyValidated: isKeyValidated ?? this.isKeyValidated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      validationAttempts: validationAttempts ?? this.validationAttempts,
      isFirstTimeSetup: isFirstTimeSetup ?? this.isFirstTimeSetup,
      isAppLocked: isAppLocked ?? this.isAppLocked,
      lockErrorMessage: lockErrorMessage ?? this.lockErrorMessage,
    );
  }
}
