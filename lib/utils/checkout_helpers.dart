import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';

class CheckoutHelpers {
  CheckoutHelpers._();

  static double uniqueItemSellPrice(UniqueItemModel unit) {
    return CalculationFormula.getItemSellPrice(
      originalPrice: unit.originalPrice,
      profitPrice: unit.profitPrice,
      taxPercentage: unit.taxPercentage,
    );
  }

  static double uniqueItemPriceAfterPromotion(
    UniqueItemModel unit,
    PromotionModel? promotion,
  ) {
    return CalculationFormula.getItemAfterPromotionPrice(
      sellPrice: uniqueItemSellPrice(unit),
      promotionPercentage: promotion?.promotionPercentage,
      promotionPrice: promotion?.promotionPrice,
    );
  }

  static PromotionModel? promotionForItem(
    int itemId, {
    required List<PromotionModel> activePromotionList,
    required List<dynamic> itemPromotionList,
  }) {
    for (final joint in itemPromotionList) {
      if (joint.itemId == itemId) {
        return activePromotionList
            .cast<PromotionModel?>()
            .firstWhere(
              (p) => p?.id == joint.promotionId,
              orElse: () => null,
            );
      }
    }
    return null;
  }

  /// Subtotal from actual unique units in cart (correct for clothing per-piece pricing).
  static double cartSubtotal({
    required List<UniqueItemModel> uniqueItemList,
    required List<PromotionModel> activePromotionList,
    required List<dynamic> itemPromotionList,
  }) {
    double total = 0;
    for (final unit in uniqueItemList) {
      final promo = _promoForItemId(
        unit.itemId,
        activePromotionList: activePromotionList,
        itemPromotionList: itemPromotionList,
      );
      total += uniqueItemPriceAfterPromotion(unit, promo);
    }
    return total;
  }

  static PromotionModel? _promoForItemId(
    int itemId, {
    required List<PromotionModel> activePromotionList,
    required List<dynamic> itemPromotionList,
  }) {
    for (final joint in itemPromotionList) {
      try {
        if (joint.itemId == itemId) {
          for (final promo in activePromotionList) {
            if (promo.id == joint.promotionId) return promo;
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// FEFO: soonest expiry first; excludes units already in cart.
  static UniqueItemModel? pickNextUnit({
    required List<UniqueItemModel> availableUnits,
    required List<UniqueItemModel> cartUnits,
    required BusinessType businessType,
  }) {
    final inCartIds = cartUnits.map((e) => e.id).toSet();
    final pool = availableUnits.where((u) => !inCartIds.contains(u.id)).toList();
    if (pool.isEmpty) return null;

    if (businessType == BusinessType.grocery ||
        businessType == BusinessType.basicPharmacy) {
      pool.sort((a, b) {
        final ae = a.itemExpireDate;
        final be = b.itemExpireDate;
        if (ae == null && be == null) return a.id.compareTo(b.id);
        if (ae == null) return 1;
        if (be == null) return -1;
        return ae.compareTo(be);
      });
    }

    for (final unit in pool) {
      if (isExpired(unit)) continue;
      return unit;
    }
    return null;
  }

  static bool isExpired(UniqueItemModel unit) {
    final exp = unit.itemExpireDate;
    if (exp == null) return false;
    return exp.isBefore(DateTime.now());
  }

  static bool isNearExpiry(UniqueItemModel unit, {int withinDays = 7}) {
    final exp = unit.itemExpireDate;
    if (exp == null) return false;
    final now = DateTime.now();
    if (exp.isBefore(now)) return true;
    return exp.difference(now).inDays <= withinDays;
  }

  static List<String> unitDetailLines({
    required BusinessType businessType,
    required UniqueItemModel unit,
    ItemBusinessDetailModel? itemDetail,
  }) {
    final lines = <String>[];

    if (businessType == BusinessType.clothing &&
        unit.instanceLength != null &&
        unit.instanceWidth != null) {
      lines.add(
        '${unit.instanceLength} × ${unit.instanceWidth}',
      );
    }

    if (businessType == BusinessType.basicPharmacy &&
        unit.instanceBatchNumber != null &&
        unit.instanceBatchNumber!.isNotEmpty) {
      lines.add('Batch: ${unit.instanceBatchNumber}');
    }

    if ((businessType == BusinessType.grocery ||
            businessType == BusinessType.basicPharmacy) &&
        unit.itemExpireDate != null) {
      lines.add('Exp: ${TextFormatters.getDate(unit.itemExpireDate!)}');
    }

    if (itemDetail != null && businessType != BusinessType.clothing) {
      lines.addAll(itemDetail.summaryLines(businessType).take(2));
    } else if (itemDetail != null &&
        businessType == BusinessType.clothing &&
        itemDetail.clothingColor != null) {
      lines.add('Color: ${itemDetail.clothingColor}');
    }

    return lines;
  }

  static List<ItemModel> findItemsByBarcode(
    String barcode,
    List<ItemModel> items,
  ) {
    final query = barcode.trim().toLowerCase();
    if (query.isEmpty) return [];
    return items.where((item) {
      final code = item.code?.trim().toLowerCase();
      return code != null && code == query;
    }).toList();
  }

  /// Per-item aggregates for history / stockOutItem rows.
  static ({
    double avgOriginal,
    double avgSell,
    double avgFinal,
    double lineTotal,
  }) aggregateForItem({
    required int itemId,
    required List<UniqueItemModel> cartUnits,
    PromotionModel? promotion,
  }) {
    final units = cartUnits.where((u) => u.itemId == itemId).toList();
    if (units.isEmpty) {
      return (
        avgOriginal: 0,
        avgSell: 0,
        avgFinal: 0,
        lineTotal: 0,
      );
    }

    double sumOriginal = 0;
    double sumSell = 0;
    double sumFinal = 0;
    for (final u in units) {
      sumOriginal += u.originalPrice;
      final sell = uniqueItemSellPrice(u);
      sumSell += sell;
      sumFinal += uniqueItemPriceAfterPromotion(u, promotion);
    }
    final count = units.length;
    return (
      avgOriginal: sumOriginal / count,
      avgSell: sumSell / count,
      avgFinal: sumFinal / count,
      lineTotal: sumFinal,
    );
  }
}
