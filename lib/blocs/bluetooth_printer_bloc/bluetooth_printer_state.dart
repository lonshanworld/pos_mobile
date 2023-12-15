part of 'bluetooth_printer_cubit.dart';


@immutable
abstract class BluetoothPrinterState {
  final bool bluetoothOpened;
  final bool gpsOpened;
  final BluetoothConnection? bluetoothConnection;
  final String? printerName;
  final PaperSizeModel paperSizeModel;
  const BluetoothPrinterState({
    required this.bluetoothOpened,
    required this.gpsOpened,
    required this.bluetoothConnection,
    required this.printerName,
    required this.paperSizeModel,
  });
}

class BluetoothPrinterData extends BluetoothPrinterState {
  const BluetoothPrinterData({required super.bluetoothOpened, required super.bluetoothConnection, required super.printerName,required super.paperSizeModel, required super.gpsOpened});
}
