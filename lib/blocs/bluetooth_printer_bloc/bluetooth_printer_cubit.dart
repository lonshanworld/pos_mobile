import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter/material.dart";
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/models/papersize_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

part 'bluetooth_printer_state.dart';

class BluetoothPrinterCubit extends Cubit<BluetoothPrinterState> {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  BluetoothPrinterCubit()
      : super(const BluetoothPrinterData(
          bluetoothOpened: false,
          bluetoothConnection: BluetoothConnection.disconnected,
          printerName: null,
          paperSizeModel: PaperSizeModel(
            paperSize: PaperSize.mm58,
            sizeName: "Small",
          ),
          gpsOpened: false,
        )) {
    checkPermission();
    _initConnectionListener();
  }

  List<BluetoothDevice> _scanResults = [];
  List<BluetoothDevice> get scanResults => _scanResults;

  void _initConnectionListener() {
    _bluetooth.onStateChanged().listen((stateStr) {
      if (stateStr == BlueThermalPrinter.CONNECTED) {
        emit(BluetoothPrinterData(
          bluetoothOpened: state.bluetoothOpened,
          bluetoothConnection: BluetoothConnection.connected,
          printerName: state.printerName,
          paperSizeModel: state.paperSizeModel,
          gpsOpened: state.gpsOpened,
          connectedDevice: state.connectedDevice,
        ));
      } else if (stateStr == BlueThermalPrinter.DISCONNECTED) {
        emit(BluetoothPrinterData(
          bluetoothOpened: state.bluetoothOpened,
          bluetoothConnection: BluetoothConnection.disconnected,
          printerName: null,
          paperSizeModel: state.paperSizeModel,
          gpsOpened: state.gpsOpened,
          connectedDevice: null,
        ));
      }
    });
  }

  Future<void> checkPermission() async {
    // Request Bluetooth and Location permissions for Android 12+
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.locationWhenInUse.request();

    bool? isAvailable = await _bluetooth.isAvailable;
    bool? isOn = await _bluetooth.isOn;
    bool isGpsOn = await Geolocator.isLocationServiceEnabled();

    emit(BluetoothPrinterData(
      bluetoothOpened: (isAvailable == true && isOn == true),
      bluetoothConnection: state.bluetoothConnection,
      printerName: state.printerName,
      paperSizeModel: state.paperSizeModel,
      gpsOpened: isGpsOn,
      connectedDevice: state.connectedDevice,
    ));
    
    if (isOn == true && isGpsOn) {
      startScanning();
    }
  }

  Future<void> startScanning() async {
    try {
      _scanResults = await _bluetooth.getBondedDevices();
      
      // Force UI rebuild
      emit(BluetoothPrinterData(
        bluetoothOpened: state.bluetoothOpened,
        bluetoothConnection: state.bluetoothConnection,
        printerName: state.printerName,
        paperSizeModel: state.paperSizeModel,
        gpsOpened: state.gpsOpened,
        connectedDevice: state.connectedDevice,
      ));
    } catch (e) {
      cusDebugPrint("Scan error: $e");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    emit(BluetoothPrinterData(
      bluetoothOpened: state.bluetoothOpened,
      bluetoothConnection: BluetoothConnection.connecting,
      printerName: device.name,
      paperSizeModel: state.paperSizeModel,
      gpsOpened: state.gpsOpened,
      connectedDevice: device,
    ));

    try {
      bool? isConnected = await _bluetooth.isConnected;
      if (isConnected == true) {
        await _bluetooth.disconnect();
      }

      await _bluetooth.connect(device);
      
      emit(BluetoothPrinterData(
        bluetoothOpened: state.bluetoothOpened,
        bluetoothConnection: BluetoothConnection.connected,
        printerName: device.name,
        paperSizeModel: state.paperSizeModel,
        gpsOpened: state.gpsOpened,
        connectedDevice: device,
      ));
    } catch (e) {
      cusDebugPrint("Connect error: $e");
      emit(BluetoothPrinterData(
        bluetoothOpened: state.bluetoothOpened,
        bluetoothConnection: BluetoothConnection.disconnected,
        printerName: null,
        paperSizeModel: state.paperSizeModel,
        gpsOpened: state.gpsOpened,
        connectedDevice: null,
      ));
    }
  }

  Future<void> disconnectPrinter() async {
    try {
      await _bluetooth.disconnect();
    } catch (e) {
      cusDebugPrint("Disconnect error: $e");
    }
    emit(BluetoothPrinterData(
      bluetoothOpened: state.bluetoothOpened,
      bluetoothConnection: BluetoothConnection.disconnected,
      printerName: null,
      paperSizeModel: state.paperSizeModel,
      gpsOpened: state.gpsOpened,
      connectedDevice: null,
    ));
  }

  void setPaperSize(PaperSizeModel paperSizeModel) {
    emit(BluetoothPrinterData(
      bluetoothOpened: state.bluetoothOpened,
      bluetoothConnection: state.bluetoothConnection,
      printerName: state.printerName,
      paperSizeModel: paperSizeModel,
      gpsOpened: state.gpsOpened,
      connectedDevice: state.connectedDevice,
    ));
  }

  Future<Uint8List?> convertWidgetToImage(GlobalKey key) async {
    try {
      await WidgetsBinding.instance.endOfFrame;

      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 120));
        await WidgetsBinding.instance.endOfFrame;
      }

      final image = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      cusDebugPrint("Widget to image error: $e");
      return null;
    }
  }

  Future<bool> printVoucher(GlobalKey printKey) async {
    bool? isConnected = await _bluetooth.isConnected;
    if (isConnected != true) {
      cusDebugPrint("Printer not connected");
      return false;
    }

    Uint8List? pngBytes = await convertWidgetToImage(printKey);
    if (pngBytes == null) {
      cusDebugPrint("Failed to capture voucher image");
      return false;
    }

    try {
      // Decode the PNG image
      final img.Image? decodedImage = img.decodePng(pngBytes);
      if (decodedImage == null) {
        cusDebugPrint("Failed to decode PNG");
        return false;
      }

      // Generate ESC/POS commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(state.paperSizeModel.paperSize, profile);
      List<int> bytes = [];

      // Reset printer
      bytes += generator.reset();

      // Resize the image to fit the paper width
      final int paperWidthPx = state.paperSizeModel.paperSize.width;
      final img.Image resized = img.copyResize(decodedImage, width: paperWidthPx);

      // Print image
      bytes += generator.imageRaster(resized, align: PosAlign.center);

      // Feed paper and cut
      bytes += generator.feed(1);
      bytes += generator.cut();

      // Send to Bluetooth printer in chunks to reduce transport overflow.
      final payload = Uint8List.fromList(bytes);
      const chunkSize = 512;
      for (int i = 0; i < payload.length; i += chunkSize) {
        final end = math.min(i + chunkSize, payload.length);
        await _bluetooth.writeBytes(payload.sublist(i, end));
        await Future.delayed(const Duration(milliseconds: 30));
      }
      
      cusDebugPrint("Print command sent successfully to ${state.printerName}");
      return true;
    } catch (e) {
      cusDebugPrint("Print error: $e");
      return false;
    }
  }

  Future<Uint8List?> generateVoucherPdf(GlobalKey printKey) async {
    final pngBytes = await convertWidgetToImage(printKey);
    if (pngBytes == null) {
      cusDebugPrint("Failed to capture voucher image for PDF");
      return null;
    }

    final img.Image? decodedImage = img.decodePng(pngBytes);
    if (decodedImage == null) {
      cusDebugPrint("Failed to decode voucher image for PDF");
      return null;
    }

    try {
      final doc = pw.Document();
      final paperWidthMm =
          state.paperSizeModel.paperSize == PaperSize.mm80 ? 80.0 : 58.0;
      final pageWidth = paperWidthMm * PdfPageFormat.mm;
      final ratio = decodedImage.height / decodedImage.width;
      final imageHeight = pageWidth * ratio;

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, imageHeight + (6 * PdfPageFormat.mm)),
          margin: pw.EdgeInsets.all(3 * PdfPageFormat.mm),
          build: (_) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(pngBytes),
                width: pageWidth,
                fit: pw.BoxFit.fitWidth,
              ),
            );
          },
        ),
      );

      return doc.save();
    } catch (e) {
      cusDebugPrint("PDF generation error: $e");
      return null;
    }
  }

  Future<String?> downloadVoucherPdf(GlobalKey printKey, {String? fileName}) async {
    try {
      final pdfBytes = await generateVoucherPdf(printKey);
      if (pdfBytes == null) return null;

      // Build save path: Documents/nanonux/vouchers/ on external storage
      Directory? vouchersDir;
      try {
        if (Platform.isAndroid) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            final androidIndex = externalDir.path.indexOf('/Android/');
            if (androidIndex != -1) {
              final rootPath = externalDir.path.substring(0, androidIndex);
              final candidate = Directory('$rootPath/Documents/nanonux/vouchers');
              // Try to create the folder if it doesn't exist yet
              if (!await candidate.exists()) {
                await candidate.create(recursive: true);
              }
              // Verify we can actually write there
              final testFile = File('${candidate.path}/.write_test');
              await testFile.writeAsBytes([]);
              await testFile.delete();
              vouchersDir = candidate;
            }
          }
        }
      } catch (_) {
        vouchersDir = null; // creation or write-test failed → use fallback
      }

      // Fallback: app documents dir (always writable, no permission needed)
      if (vouchersDir == null) {
        final appDocsDir = await getApplicationDocumentsDirectory();
        vouchersDir = Directory('${appDocsDir.path}/nanonux/vouchers');
        if (!await vouchersDir.exists()) {
          await vouchersDir.create(recursive: true);
        }
      }

      final cleanName = _sanitizeFileName(
        fileName ?? 'voucher_${DateTime.now().millisecondsSinceEpoch}',
      );
      final file = File('${vouchersDir.path}/$cleanName.pdf');
      await file.writeAsBytes(pdfBytes);

      cusDebugPrint('PDF saved to: ${file.path}');
      return file.path;
    } catch (e) {
      cusDebugPrint('PDF save error: $e');
      return null;
    }
  }

  String _sanitizeFileName(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (cleaned.trim().isEmpty) {
      return 'voucher_${DateTime.now().millisecondsSinceEpoch}';
    }
    return cleaned;
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
