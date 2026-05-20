import 'package:pos_mobile/models/itemModel_with_UniqueItemcount.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:sqflite/sqflite.dart';

import '../../../constants/txtconstants.dart';

class TransactionStockOutItemDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
        """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.stockOutItemTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          stockOutId INTEGER REFERENCES ${TxtConstants.stockOutTableName}(id) NOT NULL,
          itemId INTEGER REFERENCES ${TxtConstants.itemTableName}(id) NOT NULL,
          count INTEGER NOT NULL DEFAULT 0,
          originalPrice REAL NOT NULL,
          sellPrice REAL NOT NULL,
          finalSellPrice REAL NOT NULL
        )
      """
    );
    // OPTIMIZATION: Add index for stockOutId to speed up lookup by order
    await db.execute("CREATE INDEX IF NOT EXISTS idx_stockOutItem_stockOutId ON ${TxtConstants.stockOutItemTableName}(stockOutId);");
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.stockOutItemTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db, {int limit = 5000, int offset = 0})async{
    return await db.query(
      TxtConstants.stockOutItemTableName,
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  static Future<List<int>>insertNewDataList({
    required Database db,
    required List<ItemModelWithUniqueItemCountWithPromotion> dataList,
    required int stockOutId,
  })async{
    final Batch batch = db.batch();
    for(ItemModelWithUniqueItemCountWithPromotion item in dataList){
      final double sellPrice = CalculationFormula.getItemSellPrice(originalPrice: item.itemModel.originalPrice, profitPrice: item.itemModel.profitPrice, taxPercentage: item.itemModel.taxPercentage ?? 0);
      
      batch.rawInsert(
        """
          INSERT INTO ${TxtConstants.stockOutItemTableName}
          (
            itemId,
            stockOutId,
            count,
            originalPrice,
            sellPrice,
            finalSellPrice
          )
          VALUES(?,?,?,?,?,?)
        """,
        [
          item.itemModel.id,
          stockOutId,
          item.count,
          item.itemModel.originalPrice,
          sellPrice,
          CalculationFormula.getItemAfterPromotionPrice(
            sellPrice: sellPrice,
            promotionPercentage: item.promotion == null ? 0 : item.promotion!.promotionPercentage,
            promotionPrice: item.promotion == null ? 0 : item.promotion!.promotionPrice,
          ),
        ],
      );
    }

    final List<int> results = (await batch.commit()).map((e) => e is int ? e : null).cast<int>().toList();
    return results;
  }
}