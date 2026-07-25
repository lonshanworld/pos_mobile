import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/languages/app_language.dart';
import 'package:pos_mobile/languages/app_strings.dart';

class LanguageSettingsScreen extends StatelessWidget {
  static const routeName = '/settings/language';
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final selected = context.watch<LanguageCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(strings.language)),
      body: ListView(
        padding: const EdgeInsets.all(UIConstants.bigSpace),
        children: [
          Text(strings.languageDescription, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: UIConstants.mediumSpace),
          RadioGroup<AppLanguage>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) context.read<LanguageCubit>().setLanguage(value);
            },
            child: Column(
              children: AppLanguage.values
                  .map((language) => Card(
                        child: RadioListTile<AppLanguage>(
                          value: language,
                          title: Text(language.displayName),
                          subtitle: Text(language.currency),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
