import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

enum AppLanguage { myanmar, english, thai }

const AppLanguage defaultAppLanguage = AppLanguage.english;

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
        AppLanguage.myanmar => 'my',
        AppLanguage.english => 'en',
        AppLanguage.thai => 'th',
      };

  String get displayName => switch (this) {
        AppLanguage.myanmar => 'မြန်မာ',
        AppLanguage.english => 'English',
        AppLanguage.thai => 'ไทย',
      };

  String get currency => this == AppLanguage.thai ? 'Baht' : 'MMK';
}

AppLanguage appLanguageFromCode(String? code) => AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => defaultAppLanguage,
    );

class LanguageCubit extends Cubit<AppLanguage> {
  static const storageKey = 'APP_LANGUAGE';
  final GetStorage _storage;

  LanguageCubit({GetStorage? storage})
      : _storage = storage ?? GetStorage(),
        super(appLanguageFromCode((storage ?? GetStorage()).read<String>(storageKey)));

  Future<void> setLanguage(AppLanguage language) async {
    if (state == language) return;
    await _storage.write(storageKey, language.code);
    emit(language);
  }

  static AppLanguage of(BuildContext context) => context.watch<LanguageCubit>().state;
}

class CurrencyFormatter {
  CurrencyFormatter._();

  static String code(BuildContext context) => LanguageCubit.of(context).currency;

  static String format(BuildContext context, num value, {int decimals = 0}) {
    return '${value.toStringAsFixed(decimals)} ${code(context)}';
  }
}
