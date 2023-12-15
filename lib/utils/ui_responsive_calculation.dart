import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/utils/debug_print.dart';

class UIutils{
  final UIController uiController = UIController.instance;

  double txtFieldLoginWidth(double value){
    double deviceWidth = uiController.getDeviceWidth;
    cusDebugPrint(deviceWidth);
    if(deviceWidth >= value){
      return value;
    }else{
      return deviceWidth;
    }
  }

  double voucherWidth(){
    double deviceWidth = uiController.getDeviceWidth;
    if(deviceWidth < 500){
      return deviceWidth * 5/6;
    }else{
      return 500;
    }
  }

  double stockOutBottomSheetWidth(){
    double deviceWidth = uiController.getDeviceWidth;
    if(deviceWidth > 500){
      return deviceWidth/2;
    }else{
      return 250;
    }
  }

  double stockOutHistoryWidgetWidth(){
    double deviceWidth = uiController.getDeviceWidth;
    if(deviceWidth < 350){
      return deviceWidth;
    }else{
      return 350;
    }
  }

  double stockInHistoryWidgetWidth(){
    double deviceWidth = uiController.getDeviceWidth;
    if(deviceWidth < 300){
      return deviceWidth;
    }else{
      return 300;
    }
  }

  double createUserAccountScreenWidthTextField(){
    double deviceWidth = uiController.getDeviceWidth;
    return deviceWidth > 450 ? 450 : deviceWidth;
  }

  double promotionWidgetWidth(){
    double deviceWidth = uiController.getDeviceWidth;
    if(deviceWidth < 350){
      return deviceWidth;
    }else{
      return 350;
    }
  }
}