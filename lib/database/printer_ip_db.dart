import 'package:get_storage/get_storage.dart';

class PrinterIpDb {
  final GetStorage box = GetStorage();
  final String _key = "printer_ip_address";

  Future<void> setPrinterIp(String ipAddress) async {
    await box.write(_key, ipAddress);
  }

  String? getPrinterIp() {
    return box.read(_key);
  }
}
