import 'package:get_storage/get_storage.dart';
import 'package:pos_mobile/constants/txtconstants.dart';

class FontSizeDb{
  final GetStorage box = GetStorage();

  double getFontSize(){
    return box.read(TxtConstants.printerFontSizeKey) ?? 23;
  }

  Future<void>setFontSize(double value){
    return box.write(TxtConstants.printerFontSizeKey, value);
  }
}