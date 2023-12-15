import 'package:sqflite/sqlite_api.dart';

import '../../../constants/enums.dart';
import '../../../constants/txtconstants.dart';
import '../../../models/user_model_folder/user_model.dart';

class TransactionStockOutDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.stockOutTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id), 
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          description TEXT,
          shoppingType TEXT NOT NULL,
          paymentMethod TEXT NOT NULL,
          additionalPromotionAmount REAL,
          taxPercentage REAL,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          code TEXT NOT NULL,
          customerId INTEGER REFERENCES ${TxtConstants.customerTableName}(id),
          deliveryPersonId INTEGER REFERENCES ${TxtConstants.deliveryPersonTableName}(id),
          deliveryModelId INTEGER REFERENCES ${TxtConstants.deliveryModelTableName}(id),
          finalTotalPrice REAL NOT NULL,
          customerCash REAL,
          refunds REAL
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
        """
        DROP TABLE IF EXISTS ${TxtConstants.stockOutTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    return await db.query(TxtConstants.stockOutTableName);
  }


  static Future<int>insertNewData(
      Database db,
      {
        required UserModel userModel,
        required DateTime dateTime,
        required double taxPercentage,
        required double? additionalPromotionAmount,
        required String? description,
        required ShoppingType shoppingType,
        required PaymentMethod paymentMethod,
        required String barcode,
        required int? customerId,
        required int? deliveryPersonId,
        required int? deliveryModelId,
        required double finalTotalPrice,
      }
  )async{
    return await db.rawInsert(
        """
          INSERT INTO ${TxtConstants.stockOutTableName}
          (
            createPersonId,
            createTime,
            description,
            shoppingType,
            paymentMethod,
            additionalPromotionAmount,
            taxPercentage,
            code,
            customerId,
            deliveryPersonId,
            deliveryModelId,
            finalTotalPrice
          )
          VALUES(?,?,?,?,?,?,?,?,?,?,?,?)
        """,
        [
          userModel.id,
          dateTime.toString(),
          description == "" ? null : description,
          shoppingType.name,
          paymentMethod.name,
          additionalPromotionAmount == 0 ? null : additionalPromotionAmount,
          taxPercentage,
          barcode,
          customerId,
          deliveryPersonId,
          deliveryModelId,
          finalTotalPrice,
        ]
    );
  }

  static Future<int>deActivateStockOut(
    Database db,
    {
      required UserModel userModel,
      required DateTime dateTime,
      required int stockOutId,
    }
  )async{
    return db.rawUpdate(
        """
          UPDATE ${TxtConstants.stockOutTableName}
          SET
          deletePersonId = ?,
          deleteTime = ?,
          activeStatus = ?
          WHERE id = ?
        """,
        [userModel.id, dateTime.toString(), 0, stockOutId]
    );
  }
}