import 'package:pos_mobile/database/fontsize_Db.dart';

class PrinterFontChanger{
  PrinterFontChanger._();

  static final PrinterFontChanger _instance = PrinterFontChanger._();

  static PrinterFontChanger get instance => _instance;

  static final FontSizeDb _fontSizeDb = FontSizeDb();

  double _printerFontSize = _fontSizeDb.getFontSize();

  Future<void> setPrinterFontSize(double value)async {
    _printerFontSize = value;
    await _fontSizeDb.setFontSize(value);
  }

  double get printerFontSize => _printerFontSize.toDouble();
}