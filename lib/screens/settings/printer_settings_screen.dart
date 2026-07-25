import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:pos_mobile/blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/features/printer_font_changer.dart';
import 'package:pos_mobile/models/papersize_model.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';

class PrinterSettingsScreen extends StatefulWidget {
  static const String routeName = '/printer_settings';

  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  final PrinterFontChanger printerFontChanger = PrinterFontChanger.instance;
  int? printerFontSize;

  @override
  void initState() {
    super.initState();
    setState(() {
      printerFontSize = printerFontChanger.printerFontSize.toInt();
    });
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
    final accent = uiController.accentColor();

    Widget sectionHeader(String title, IconData icon) {
      return Padding(
        padding: const EdgeInsets.only(
            top: UIConstants.bigSpace, bottom: UIConstants.mediumSpace),
        child: Row(
          children: [
            Icon(icon, color: accent, size: UIConstants.bigIcon),
            const SizedBox(width: UIConstants.mediumSpace),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: accent,
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
                    color: isActive
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    Widget connectionCard() {
      final bool isConnected = bluetoothPrinterState.bluetoothConnection ==
          BluetoothConnection.connected;
      final bool isConnecting = bluetoothPrinterState.bluetoothConnection ==
          BluetoothConnection.connecting;

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
                        bluetoothPrinterState.printerName ??
                            'No Printer Connected',
                        style:
                            Theme.of(context).textTheme.titleSmall!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isConnecting
                            ? 'Connecting...'
                            : isConnected
                                ? 'Connected & Ready'
                                : 'Tap a device below to connect',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.grey),
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
                    tooltip: 'Disconnect',
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        centerTitle: true,
        title: const Text('Printer Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.bigSpace),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bluetooth Status ──
              sectionHeader('Bluetooth Printer', Icons.bluetooth),
              Wrap(
                spacing: UIConstants.mediumSpace,
                runSpacing: UIConstants.smallSpace,
                children: [
                  statusChip(
                    'Bluetooth ${bluetoothPrinterState.bluetoothOpened ? 'ON' : 'OFF'}',
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
                      txt: 'Check Permissions',
                      verticalpadding: UIConstants.mediumSpace,
                      horizontalpadding: UIConstants.mediumSpace,
                      bdrRadius: UIConstants.smallRadius,
                      bgClr:
                          uiController.getpureOppositeClr(themeModeType),
                      func: () {
                        printerCubit.checkPermission();
                      },
                      txtStyle: Theme.of(context).textTheme.bodyMedium!,
                      txtClr:
                          uiController.getpureDirectClr(themeModeType),
                    ),
                  ),
                  const SizedBox(width: UIConstants.mediumSpace),
                  Expanded(
                    child: CusTxtElevatedBtn(
                      txt: 'Scan Devices',
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
                    'Paper Size: ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: UIConstants.mediumSpace),
                  Expanded(
                    child: DropdownButton<PaperSizeModel>(
                      isExpanded: true,
                      dropdownColor:
                          uiController.getpureDirectClr(themeModeType),
                      borderRadius: UIConstants.mediumBorderRadius,
                      value: bluetoothPrinterState.paperSizeModel,
                      items: paperSizeList
                          .map((e) => DropdownMenuItem<PaperSizeModel>(
                                value: e,
                                child: Text(
                                  '${e.sizeName} (${e.paperSize.width}px)',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium,
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

              // ── Available Devices ──
              sectionHeader('Available Devices', Icons.devices),
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
                                color:
                                    Colors.grey.withValues(alpha: 0.5)),
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
                                  : uiController
                                      .getpureOppositeClr(themeModeType),
                            ),
                            title: Text(
                              device.name ?? 'Unknown Device',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              device.address ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(color: Colors.grey),
                            ),
                            trailing: isCurrentlyConnected
                                ? const Icon(Icons.check_circle,
                                    color: Colors.amber)
                                : Icon(Icons.touch_app,
                                    color: uiController
                                        .getpureOppositeClr(themeModeType)),
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

              // ── Printer Font Size ──
              sectionHeader('Printer Font Size', Icons.format_size),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CusTxtWidget(
                      txtStyle: Theme.of(context).textTheme.bodyMedium!,
                      txt: 'Adjust the font size used when printing receipts',
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: UIConstants.mediumBorderRadius,
                      border: Border.all(
                        color: uiController
                            .getpureOppositeClr(themeModeType)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: NumberPicker(
                      minValue: 10,
                      maxValue: 70,
                      decoration: BoxDecoration(
                        color: uiController
                            .getpureOppositeClr(themeModeType)
                            .withValues(alpha: 0.08),
                        borderRadius: UIConstants.smallBorderRadius,
                      ),
                      selectedTextStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(
                            color: uiController
                                .getpureOppositeClr(themeModeType),
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
