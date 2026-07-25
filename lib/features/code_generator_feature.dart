import 'package:uuid/uuid.dart';

class CodeGenerator {
  static String getUniqueCodeForStockIn() {
    var uuid = const Uuid();
    DateTime currentDate = DateTime.now();
    int dateInt = currentDate.microsecondsSinceEpoch;
    var idString = uuid.v4();
    return "StockIn-$dateInt-$idString";
  }

  static String getUniqueCodeForStockOut() {
    var uuid = const Uuid();
    DateTime currentDate = DateTime.now();
    int dateInt = currentDate.microsecondsSinceEpoch;
    var idString = uuid.v4();
    return "StockOut-$dateInt-$idString";
  }

  static String getUniqueCodeForPromotion(String promotionName) {
    var uuid = const Uuid();
    DateTime currentDate = DateTime.now();
    int dateInt = currentDate.microsecondsSinceEpoch;
    var idString = uuid.v4();
    return "Promotion-$dateInt-$promotionName-$idString";
  }
}
