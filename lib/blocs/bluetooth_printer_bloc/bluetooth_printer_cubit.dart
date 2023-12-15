
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter/material.dart";
import 'package:geolocator/geolocator.dart';
import 'package:pos_mobile/constants/enums.dart';
import "package:flutter_blue_plus/flutter_blue_plus.dart" as fbp;
import 'package:pos_mobile/models/papersize_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';
part 'bluetooth_printer_state.dart';

class BluetoothPrinterCubit extends Cubit<BluetoothPrinterState> {
  final BluetoothPrint _bluetoothPrint = BluetoothPrint.instance;

  BluetoothPrinterCubit() : super(BluetoothPrinterData(
      bluetoothOpened: false,
      bluetoothConnection: null,
      printerName: null,
      paperSizeModel: paperSizeList.first, gpsOpened: false,
  )){
    checkPermission();
  }

  Stream<List<BluetoothDevice>> get bluetoothStream => _bluetoothPrint.scanResults;
  BluetoothPrint get bluetoothPrint => _bluetoothPrint;

  void checkPermission(){
    fbp.FlutterBluePlus.adapterState.listen((fbp.BluetoothAdapterState s) async {
      if (s == fbp.BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
        bool gpsOn = await Geolocator.isLocationServiceEnabled();
        emit(BluetoothPrinterData(bluetoothOpened: true, bluetoothConnection: null, printerName: null, paperSizeModel: state.paperSizeModel, gpsOpened: gpsOn));
        cusDebugPrint("blue opened");
        cusDebugPrint(s);
      } else {
        // show an error to the user, etc
        emit(BluetoothPrinterData(bluetoothOpened: false, bluetoothConnection: null, printerName: null,  paperSizeModel: state.paperSizeModel, gpsOpened: state.gpsOpened));
        cusDebugPrint("blue not found");
      }
    });
  }

  void startScanning() {
    cusDebugPrint("inside start scan");
    _bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    searchBluetoothDevice();
  }

  void searchBluetoothDevice() {
    _bluetoothPrint.state.listen((event) {
      cusDebugPrint(event);
      switch (event) {
        case BluetoothPrint.DISCONNECTED:
          emit(BluetoothPrinterData(bluetoothOpened: state.bluetoothOpened, bluetoothConnection: BluetoothConnection.disconnected, printerName: null,  paperSizeModel: state.paperSizeModel, gpsOpened: state.gpsOpened));
          break;
        case BluetoothPrint.CONNECTED:
          emit(BluetoothPrinterData(bluetoothOpened: state.bluetoothOpened, bluetoothConnection: BluetoothConnection.connected, printerName: state.printerName,  paperSizeModel: state.paperSizeModel, gpsOpened: state.gpsOpened));
          break;
        default:
          break;
      }
    });
  }

  void setPrinterValue(String name, BluetoothConnection bluetoothConnectionValue){
    emit(BluetoothPrinterData(bluetoothOpened: state.bluetoothOpened, bluetoothConnection: bluetoothConnectionValue, printerName: name,  paperSizeModel: state.paperSizeModel, gpsOpened: state.gpsOpened));
  }

  void setPaperSize(PaperSizeModel paperSizeModel){
    emit(BluetoothPrinterData(bluetoothOpened: state.bluetoothOpened, bluetoothConnection: state.bluetoothConnection, printerName: state.printerName,  paperSizeModel: paperSizeModel, gpsOpened: state.gpsOpened));
  }

  Future<Uint8List?> convertWidgetToBase64Image(GlobalKey key) async {
    RenderRepaintBoundary? boundary =
    key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    /// convert boundary to image
    final image = await boundary!.toImage(pixelRatio: 6);

    /// set ImageByteFormat
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  Future<void> printVoucher(GlobalKey printKey)async{
    Map<String, dynamic> config = {};
    Uint8List? uint8list =
        await convertWidgetToBase64Image(
        printKey);
    if (uint8list != null) {
      // print(uint8list);
      String base64Image = base64Encode(uint8list);
      List<LineText> list = [];
      list.add(LineText(
        type: LineText.TYPE_IMAGE,
        content: base64Image,
        align: LineText.ALIGN_CENTER,
        linefeed: 1,
        weight: 1,
        width: state.paperSizeModel.paperSize.width,
        height: 1,
      ));
      await _bluetoothPrint
          .printReceipt(config, list);
    }
  }
}
