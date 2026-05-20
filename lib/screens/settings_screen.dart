import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_mobile/blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/features/printer_font_changer.dart';
import 'package:pos_mobile/models/papersize_model.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

import '../blocs/theme_bloc/theme_cubit.dart';
import '../controller/ui_controller.dart';
import '../widgets/cusTxt_widget.dart';

class SettingScreen extends StatefulWidget {
  static const String routeName = "/settingscreen";

  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final PrinterFontChanger printerFontChanger = PrinterFontChanger.instance;
  int? printerFontSize;

  Future<void> _showEditShopInfoDialog(
    BuildContext context,
    String field,
    String currentValue,
  ) async {
    final ctrl = TextEditingController(text: currentValue);
    final cubit = context.read<ShopInfoCubit>();
    final label = _fieldLabel(field);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: ctrl,
          maxLines: field == 'shopAddress' || field == 'noReturnNote' ? 3 : 1,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    ctrl.dispose();
    if (result == null || result.isEmpty) return;

    switch (field) {
      case 'shopName':
        await cubit.updateShopName(result);
        break;
      case 'shopAddress':
        await cubit.updateShopAddress(result);
        break;
      case 'phNum':
        await cubit.updatePhNum(result);
        break;
      case 'noReturnNote':
        await cubit.updateNoReturnNote(result);
        break;
    }
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'shopName':
        return 'Shop Name';
      case 'shopAddress':
        return 'Address';
      case 'phNum':
        return 'Phone Number';
      case 'noReturnNote':
        return 'No Return Note';
      default:
        return field;
    }
  }

  Future<void> _pickShopLogo(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? picked =
        await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final supportDir = await getApplicationSupportDirectory();
      final logoDir = Directory('${supportDir.path}/shop_logo');
      await logoDir.create(recursive: true);

      final ext = picked.path.split('.').last.toLowerCase();
      final destPath = '${logoDir.path}/logo.$ext';
      await File(picked.path).copy(destPath);

      if (!context.mounted) return;
      await context.read<ShopInfoCubit>().updateLogoPath(destPath);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save logo: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showChangeOwnerPasswordDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Owner Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current password'),
              ),
              const SizedBox(height: UIConstants.mediumSpace),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              const SizedBox(height: UIConstants.mediumSpace),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm new password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final msg = await context.read<UserDataCubit>().changeOwnerPassword(
                  currentPassword: currentController.text.trim(),
                  newPassword: newController.text.trim(),
                  confirmPassword: confirmController.text.trim(),
                );

                if (!context.mounted) return;
                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg ?? 'Owner password updated successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        printerFontSize = printerFontChanger.printerFontSize.toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final BluetoothPrinterState bluetoothPrinterState =
        context.watch<BluetoothPrinterCubit>().state;
    final BluetoothPrinterCubit printerCubit =
        context.read<BluetoothPrinterCubit>();
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType =
        context.watch<ThemeCubit>().state.themeModeType;
    final currentUser = context.watch<UserDataCubit>().state.userModel;
    final bool isOwner = currentUser?.userLevel == UserLevel.merchant ||
      currentUser?.userLevel == UserLevel.superAdmin;
    final ShopInfoState shopInfoState = context.watch<ShopInfoCubit>().state;

    // --- Helper Widgets ---
    Widget sectionHeader(String title, IconData icon) {
      return Padding(
        padding: const EdgeInsets.only(
            top: UIConstants.bigSpace, bottom: UIConstants.mediumSpace),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: UIConstants.bigIcon),
            const SizedBox(width: UIConstants.mediumSpace),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.deepPurple,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    Widget statusChip(String label, bool isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.mediumSpace,
          vertical: UIConstants.smallSpace,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.15),
          borderRadius: UIConstants.smallBorderRadius,
          border: Border.all(
            color: isActive ? Colors.green : Colors.red.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.cancel,
              color: isActive ? Colors.green : Colors.red,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    Widget connectionCard() {
      final bool isConnected =
          bluetoothPrinterState.bluetoothConnection == BluetoothConnection.connected;
      final bool isConnecting =
          bluetoothPrinterState.bluetoothConnection == BluetoothConnection.connecting;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(UIConstants.bigSpace),
        decoration: BoxDecoration(
          color: isConnected
              ? Colors.amber.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.08),
          borderRadius: UIConstants.mediumBorderRadius,
          border: Border.all(
            color: isConnected
                ? Colors.amber.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConnected ? Icons.print : Icons.print_disabled,
                  color: isConnected ? Colors.amber : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: UIConstants.mediumSpace),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bluetoothPrinterState.printerName ?? "No Printer Connected",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isConnecting
                            ? "Connecting..."
                            : isConnected
                                ? "Connected & Ready"
                                : "Tap a device below to connect",
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                if (isConnected)
                  IconButton(
                    onPressed: () {
                      printerCubit.disconnectPrinter();
                    },
                    icon: const Icon(Icons.link_off, color: Colors.red),
                    tooltip: "Disconnect",
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section 1: Bluetooth Status ──
              sectionHeader("Bluetooth Printer", Icons.bluetooth),
              Wrap(
                spacing: UIConstants.mediumSpace,
                runSpacing: UIConstants.smallSpace,
                children: [
                  statusChip(
                    "Bluetooth ${bluetoothPrinterState.bluetoothOpened ? 'ON' : 'OFF'}",
                    bluetoothPrinterState.bluetoothOpened,
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.mediumSpace),

              // ── Connection Card ──
              connectionCard(),
              const SizedBox(height: UIConstants.mediumSpace),

              // ── Action Buttons ──
              Row(
                children: [
                  Expanded(
                    child: CusTxtElevatedBtn(
                      txt: "Check Permissions",
                      verticalpadding: UIConstants.mediumSpace,
                      horizontalpadding: UIConstants.mediumSpace,
                      bdrRadius: UIConstants.smallRadius,
                      bgClr: uiController.getpureOppositeClr(themeModeType),
                      func: () {
                        printerCubit.checkPermission();
                      },
                      txtStyle: Theme.of(context).textTheme.bodyMedium!,
                      txtClr: uiController.getpureDirectClr(themeModeType),
                    ),
                  ),
                  const SizedBox(width: UIConstants.mediumSpace),
                  Expanded(
                    child: CusTxtElevatedBtn(
                      txt: "Scan Devices",
                      verticalpadding: UIConstants.mediumSpace,
                      horizontalpadding: UIConstants.mediumSpace,
                      bdrRadius: UIConstants.smallRadius,
                      bgClr: bluetoothPrinterState.bluetoothOpened
                          ? Colors.amber
                          : Colors.grey,
                      func: () {
                        if (bluetoothPrinterState.bluetoothOpened) {
                          printerCubit.startScanning();
                        }
                      },
                      txtStyle: Theme.of(context).textTheme.bodyMedium!,
                      txtClr: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.mediumSpace),

              // ── Paper Size ──
              Row(
                children: [
                  Text(
                    "Paper Size: ",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: UIConstants.mediumSpace),
                  Expanded(
                    child: DropdownButton<PaperSizeModel>(
                      isExpanded: true,
                      dropdownColor: uiController.getpureDirectClr(themeModeType),
                      borderRadius: UIConstants.mediumBorderRadius,
                      value: bluetoothPrinterState.paperSizeModel,
                      items: paperSizeList
                          .map((e) => DropdownMenuItem<PaperSizeModel>(
                                value: e,
                                child: Text(
                                  "${e.sizeName} (${e.paperSize.width}px)",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ))
                          .toList(),
                      onChanged: (data) {
                        printerCubit.setPaperSize(data!);
                      },
                    ),
                  ),
                ],
              ),

              const CusDividerWidget(clr: Colors.grey),

              // ── Section 2: Available Devices ──
              sectionHeader("Available Devices", Icons.devices),
              BlocBuilder<BluetoothPrinterCubit, BluetoothPrinterState>(
                builder: (ctx, printerState) {
                  final devices = printerCubit.scanResults;
                  if (devices.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.bigSpace),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.bluetooth_searching,
                                size: 48,
                                color: Colors.grey.withValues(alpha: 0.5)),
                            const SizedBox(height: UIConstants.mediumSpace),
                            Text(
                              "No devices found.\nTap 'Scan Devices' to search.",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: devices.map((device) {
                        final isCurrentlyConnected =
                            printerState.connectedDevice?.address ==
                                device.address;
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(
                              vertical: UIConstants.smallSpace),
                          shape: RoundedRectangleBorder(
                            borderRadius: UIConstants.mediumBorderRadius,
                            side: BorderSide(
                              color: isCurrentlyConnected
                                  ? Colors.amber
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.bigSpace,
                              vertical: UIConstants.smallSpace,
                            ),
                            leading: Icon(
                              Icons.print,
                              size: UIConstants.normalNormalIconSize,
                              color: isCurrentlyConnected
                                  ? Colors.amber
                                  : uiController.getpureOppositeClr(themeModeType),
                            ),
                            title: Text(
                              device.name ?? "Unknown Device",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              device.address ?? "",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.grey),
                            ),
                            trailing: isCurrentlyConnected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.amber)
                                : Icon(Icons.touch_app,
                                    color: uiController.getpureOppositeClr(themeModeType)),
                            onTap: () async {
                              if (!isCurrentlyConnected) {
                                await printerCubit.connectToDevice(device);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),

              const SizedBox(height: UIConstants.bigSpace),
              const CusDividerWidget(clr: Colors.grey),

              if (isOwner) ...[
                sectionHeader("Owner Security", Icons.lock_outline),
                CusTxtElevatedBtn(
                  txt: "Change Owner Password",
                  verticalpadding: UIConstants.mediumSpace,
                  horizontalpadding: UIConstants.mediumSpace,
                  bdrRadius: UIConstants.smallRadius,
                  bgClr: uiController.getpureOppositeClr(themeModeType),
                  func: () => _showChangeOwnerPasswordDialog(context),
                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                  txtClr: uiController.getpureDirectClr(themeModeType),
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                const CusDividerWidget(clr: Colors.grey),

                // ── Shop Information ──
                sectionHeader("Shop Information", Icons.store_outlined),
                _InfoTile(
                  label: 'Shop Name',
                  value: shopInfoState.shopName,
                  onEdit: () => _showEditShopInfoDialog(context, 'shopName', shopInfoState.shopName),
                ),
                _InfoTile(
                  label: 'Address',
                  value: shopInfoState.shopAddress,
                  onEdit: () => _showEditShopInfoDialog(context, 'shopAddress', shopInfoState.shopAddress),
                ),
                _InfoTile(
                  label: 'Phone',
                  value: shopInfoState.phNum,
                  onEdit: () => _showEditShopInfoDialog(context, 'phNum', shopInfoState.phNum),
                ),
                _InfoTile(
                  label: 'No Return Note',
                  value: shopInfoState.noReturnNote,
                  onEdit: () => _showEditShopInfoDialog(context, 'noReturnNote', shopInfoState.noReturnNote),
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                const CusDividerWidget(clr: Colors.grey),

                // ── Shop Logo ──
                sectionHeader("Shop Logo", Icons.image_outlined),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LogoImageWidget(
                      widthandheight: 72 * shopInfoState.logoSizeRatio,
                      customLogoPath: shopInfoState.logoPath,
                    ),
                    const SizedBox(width: UIConstants.bigSpace),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickShopLogo(context),
                          icon: const Icon(Icons.image_outlined, size: 18),
                          label: const Text('Pick Logo'),
                        ),
                        if (shopInfoState.logoPath != null)
                          TextButton.icon(
                            onPressed: () =>
                                context.read<ShopInfoCubit>().updateLogoPath(null),
                            icon: Icon(Icons.restore,
                                color: Colors.grey.shade600, size: 18),
                            label: Text(
                              'Reset to Default',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                Row(
                  children: [
                    const Text('Logo Size Ratio: '),
                    const SizedBox(width: UIConstants.smallSpace),
                    Text(
                      shopInfoState.logoSizeRatio.toStringAsFixed(1),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  min: 0.5,
                  max: 3.0,
                  divisions: 25,
                  value: shopInfoState.logoSizeRatio,
                  label: shopInfoState.logoSizeRatio.toStringAsFixed(1),
                  onChanged: (val) {
                    context.read<ShopInfoCubit>().updateLogoSizeRatio(val);
                  },
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                const CusDividerWidget(clr: Colors.grey),
              ],

              // ── Section 3: Printer Font Size ──
              sectionHeader("Printer Font Size", Icons.format_size),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CusTxtWidget(
                      txtStyle: Theme.of(context).textTheme.bodyMedium!,
                      txt: "Adjust the font size used when printing receipts",
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: UIConstants.mediumBorderRadius,
                      border: Border.all(
                        color: uiController.getpureOppositeClr(themeModeType).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: NumberPicker(
                      minValue: 10,
                      maxValue: 70,
                      decoration: BoxDecoration(
                        color: uiController.getpureOppositeClr(themeModeType).withValues(alpha: 0.08),
                        borderRadius: UIConstants.smallBorderRadius,
                      ),
                      selectedTextStyle:
                          Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: uiController.getpureOppositeClr(themeModeType),
                                fontWeight: FontWeight.bold,
                              ),
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      value: printerFontSize ?? 23,
                      onChanged: (data) async {
                        if (mounted) {
                          await printerFontChanger
                              .setPrinterFontSize(data.toDouble());
                          setState(() {
                            printerFontSize = data;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.bigSpace * 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.smallSpace),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
