import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:pos_mobile/blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/papersize_model.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';

import '../blocs/theme_bloc/theme_cubit.dart';
import '../controller/ui_controller.dart';
import '../feature/printer_font_changer.dart';
import '../widgets/cusTxt_widget.dart';

class SettingScreen extends StatefulWidget {
  static const String routeName = "/settingscreen";

  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // bool showSearching = false;
  final PrinterFontChanger printerFontChanger = PrinterFontChanger.instance;
  int? printerFontSize;


  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        printerFontSize = printerFontChanger.printerFontSize.toInt();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final BluetoothPrinterState bluetoothPrinterState = context.watch<BluetoothPrinterCubit>().state;
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;



    // void startScanning() {
    //   bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    //   if (mounted) {
    //     setState(() {
    //       showSearching = true;
    //       showDevice = true;
    //     });
    //   }
    // }
    //
    // void searchBluetoothDevice() {
    //   bluetoothPrint.state.listen((event) {
    //     switch (event) {
    //       case BluetoothPrint.DISCONNECTED:
    //         if (mounted) {
    //           con
    //         }
    //         break;
    //       case BluetoothPrint.CONNECTED:
    //         if (mounted) {
    //           setState(() {
    //             titleTwo = "Connected";
    //             titleTwoColor = Colors.green.shade700;
    //             showDevice = false;
    //             hasDevice = true;
    //             showSearching = false;
    //           });
    //         }
    //         break;
    //       default:
    //         break;
    //     }
    //   });
    // }

    Widget checkBtn(VoidCallback func, String txt){
      return CusTxtElevatedBtn(
          txt: txt,
          verticalpadding: UIConstants.smallSpace,
          horizontalpadding: UIConstants.mediumSpace,
          bdrRadius: UIConstants.smallRadius,
          bgClr: Colors.grey,
          func: func,
          txtStyle: Theme.of(context).textTheme.bodyMedium!,
          txtClr: Colors.black,
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              CusTxtWidget(
                txt: "Bluetooth printer settings",
                txtStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.grey
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
              CusTxtWidget(
                txt: "Bluetooth : ${bluetoothPrinterState.bluetoothOpened}",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey
                ),
              ),
              CusTxtWidget(
                txt: "GPS : ${bluetoothPrinterState.gpsOpened}",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey
                ),
              ),
              CusTxtWidget(
                txt: "Bluetooth Connection : ${bluetoothPrinterState.bluetoothConnection ?? "not found"}",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey
                ),
              ),
              CusTxtWidget(
                txt: "Printer Name : ${bluetoothPrinterState.printerName ?? "not found"}",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey
                ),
              ),
              CusTxtWidget(
                txt: "Paper Size : ${bluetoothPrinterState.paperSizeModel.sizeName}",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.grey
                ),
              ),
              // ElevatedButton(onPressed: (){
              //   context.read<BluetoothPrinterCubit>().checkPermission();
              // }, child: Text("Check bluetooth")),
              // ElevatedButton(
              //   onPressed: (){
              //     context.read<BluetoothPrinterCubit>().startScanning();
              //   },
              //   child: Text("Start scan"),
              // ),
              checkBtn(
                    () {
                      context.read<BluetoothPrinterCubit>().checkPermission();
                    },
                "Check require permission",
              ),
              checkBtn(
                    () {
                      context.read<BluetoothPrinterCubit>().startScanning();
                    },
                "Start scan",
              ),
              DropdownButton(
                dropdownColor: uiController.getpureDirectClr(themeModeType),
                borderRadius: UIConstants.mediumBorderRadius,
                value: bluetoothPrinterState.paperSizeModel,
                items: paperSizeList.map((e) => DropdownMenuItem<PaperSizeModel>(
                  value: e,
                  child: Text(
                    e.sizeName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                )).toList(),
                onChanged: (data){
                  context.read<BluetoothPrinterCubit>().setPaperSize(data!);
                },
              ),
              const CusDividerWidget(clr: Colors.grey),
              BlocBuilder<BluetoothPrinterCubit, BluetoothPrinterState>(
                builder: (ctx, state){
                  return StreamBuilder<List<BluetoothDevice>>(
                    stream: ctx.read<BluetoothPrinterCubit>().bluetoothStream,
                    builder: (bluetoothCtx, snapshot){
                      if(snapshot.data == null){
                        return CusTxtWidget(
                          txtStyle: Theme.of(context).textTheme.titleSmall!,
                          txt: "getting bluetooth devices",
                        );
                      }else if(snapshot.data!.isEmpty){
                        return CusTxtWidget(
                          txtStyle: Theme.of(context).textTheme.titleSmall!,
                          txt: "Bluetooth device not found",
                        );
                      }else{
                        return SingleChildScrollView(
                          child: Column(
                            children: snapshot.data!.map((d) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.print,
                                  size: UIConstants.normalNormalIconSize,
                                ),
                                title: Text(
                                  d.name ?? "",
                                ),
                                subtitle: Text(
                                  d.address ?? "",
                                ),
                                onTap: ()async{
                                  ctx.read<BluetoothPrinterCubit>().setPrinterValue(d.name ?? "Bluetooth Printer", BluetoothConnection.connecting);
                                  ctx.read<BluetoothPrinterCubit>().searchBluetoothDevice();
                                  await ctx.read<BluetoothPrinterCubit>().bluetoothPrint.connect(d);
                                },
                                trailing: const Icon(
                                  Icons.touch_app,
                                  size: UIConstants.normalNormalIconSize,
                                  color: Colors.blue,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace * 3, cusWidth: null),
              CusTxtWidget(
                txt: "Printer Font-Size Setting",
                txtStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.grey
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleSmall!,
                    txt: "Choose font-size for printer",
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: UIConstants.bigBorderRadius,
                        border: Border.all(
                          color: Colors.tealAccent,
                          width: 1,
                        )
                    ),
                    child: NumberPicker(
                      minValue: 10,
                      maxValue: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                      ),
                      selectedTextStyle: Theme.of(context).textTheme.titleMedium!,
                      textStyle: Theme.of(context).textTheme.bodyMedium,
                      value: printerFontSize ?? 23,
                      onChanged: (data)async{
                        if(mounted){
                          await printerFontChanger.setPrinterFontSize(data.toDouble());
                          setState(() {
                            printerFontSize = data;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
