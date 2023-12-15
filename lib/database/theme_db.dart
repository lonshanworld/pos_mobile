import 'package:get_storage/get_storage.dart';
import 'package:pos_mobile/constants/txtconstants.dart';

class ThemeDB{
  final GetStorage box = GetStorage();

  bool getThemeDbData(){
    return box.read(TxtConstants.themeDbKey) ?? true;
  }

  Future<void> setThemeDbData(bool value){
    return box.write(TxtConstants.themeDbKey, value);
  }
}