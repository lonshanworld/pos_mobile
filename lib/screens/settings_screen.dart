import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/screens/settings/general_settings_screen.dart';
import 'package:pos_mobile/screens/settings/printer_settings_screen.dart';

import '../blocs/theme_bloc/theme_cubit.dart';
import '../blocs/userData_bloc/user_data_cubit.dart';
import '../controller/ui_controller.dart';

class SettingScreen extends StatelessWidget {
  static const String routeName = '/settingscreen';

  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType =
        context.watch<ThemeCubit>().state.themeModeType;
    final currentUser = context.watch<UserDataCubit>().state.userModel;
    final bool isOwner = currentUser?.userLevel == UserLevel.merchant ||
        currentUser?.userLevel == UserLevel.superAdmin;
    final BluetoothPrinterState printerState =
        context.watch<BluetoothPrinterCubit>().state;
    final accent = uiController.accentColor();

    final bool isPrinterConnected =
        printerState.bluetoothConnection == BluetoothConnection.connected;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
          vertical: UIConstants.mediumSpace,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: UIConstants.mediumSpace),

            Text(
              'Manage your preferences and configuration',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.grey),
            ),
            const SizedBox(height: UIConstants.bigSpace),

            // ── Printer Settings Card ──
            _SettingHubCard(
              icon: Icons.print_outlined,
              title: 'Printer Settings',
              subtitle: isPrinterConnected
                  ? 'Connected: ${printerState.printerName ?? "Printer"}'
                  : 'No printer connected',
              statusDot: isPrinterConnected ? Colors.green : Colors.grey,
              accentColor: Colors.amber,
              themeModeType: themeModeType,
              uiController: uiController,
              onTap: () => Navigator.of(context)
                  .pushNamed(PrinterSettingsScreen.routeName),
            ),
            const SizedBox(height: UIConstants.mediumSpace),

            // ── General Settings Card ──
            _SettingHubCard(
              icon: Icons.tune_outlined,
              title: 'General Settings',
              subtitle: isOwner
                  ? 'Shop info, business type, logo & security'
                  : 'View shop information',
              statusDot: null,
              accentColor: accent,
              themeModeType: themeModeType,
              uiController: uiController,
              onTap: () => Navigator.of(context)
                  .pushNamed(GeneralSettingsScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingHubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? statusDot;
  final Color accentColor;
  final ThemeModeType themeModeType;
  final UIController uiController;
  final VoidCallback onTap;

  const _SettingHubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusDot,
    required this.accentColor,
    required this.themeModeType,
    required this.uiController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: UIConstants.mediumBorderRadius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(UIConstants.bigSpace),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.07),
            borderRadius: UIConstants.mediumBorderRadius,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UIConstants.mediumSpace),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: UIConstants.smallBorderRadius,
                ),
                child: Icon(icon, color: accentColor, size: 28),
              ),
              const SizedBox(width: UIConstants.bigSpace),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (statusDot != null) ...[
                          const SizedBox(width: UIConstants.smallSpace),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusDot,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
