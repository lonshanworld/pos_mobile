import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/stock_in_unit_spec.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

class StockInPieceEntry {
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  void dispose() {
    lengthController.dispose();
    widthController.dispose();
    batchController.dispose();
    costController.dispose();
  }
}

/// Builds [StockInUnitSpec] list from piece entries for clothing / pharmacy stock-in.
class StockInUnitBuilder {
  static List<StockInUnitSpec>? fromClothingPieces({
    required List<StockInPieceEntry> pieces,
    required ItemModel itemModel,
    required ItemBusinessDetailModel? businessDetail,
  }) {
    final rate = businessDetail?.pricePerMeasurementUnit;
    if (rate == null || rate <= 0) {
      throw ArgumentError('Price per measurement unit is not set or invalid for clothing.');
    }

    final specs = <StockInUnitSpec>[];
    for (final piece in pieces) {
      final length = double.tryParse(piece.lengthController.text.trim());
      final width = double.tryParse(piece.widthController.text.trim());
      final costOverride = double.tryParse(piece.costController.text.trim());

      if (length == null ||
          width == null ||
          length <= 0 ||
          width <= 0) {
        throw ArgumentError('Invalid measurements (Length and Width must be positive numbers).');
      }

      final sellBase = CalculationFormula.clothingPieceSellBase(
        length: length,
        width: width,
        pricePerMeasurementUnit: rate,
      );
      final prices = CalculationFormula.clothingPiecePrices(
        sellBase: sellBase,
        itemOriginalPrice: itemModel.originalPrice,
        itemProfitPrice: itemModel.profitPrice,
        purchaseCostOverride: costOverride,
      );

      specs.add(StockInUnitSpec(
        instanceLength: length,
        instanceWidth: width,
        originalPrice: prices.originalPrice,
        profitPrice: prices.profitPrice,
      ));
    }
    return specs;
  }

  static List<StockInUnitSpec> fromPharmacyPieces({
    required List<StockInPieceEntry> pieces,
    required ItemModel itemModel,
  }) {
    return pieces
        .map(
          (piece) => StockInUnitSpec(
            instanceBatchNumber: piece.batchController.text.trim().isEmpty
                ? null
                : piece.batchController.text.trim(),
            originalPrice: itemModel.originalPrice,
            profitPrice: itemModel.profitPrice,
          ),
        )
        .toList();
  }

  static List<StockInUnitSpec> fromPharmacyBatch({
    required String batchNumber,
    required int count,
    required ItemModel itemModel,
  }) {
    return List.generate(
      count,
      (_) => StockInUnitSpec(
        instanceBatchNumber: batchNumber,
        originalPrice: itemModel.originalPrice,
        profitPrice: itemModel.profitPrice,
      ),
    );
  }
}

class StockInPieceListForm extends StatefulWidget {
  final bool showMeasurements;
  final bool showBatchNumber;
  final bool allowMultiplePieces;
  final ItemBusinessDetailModel? businessDetail;
  final ItemModel itemModel;

  const StockInPieceListForm({
    super.key,
    required this.showMeasurements,
    required this.showBatchNumber,
    required this.allowMultiplePieces,
    required this.businessDetail,
    required this.itemModel,
  });

  @override
  StockInPieceListFormState createState() => StockInPieceListFormState();
}

class StockInPieceListFormState extends State<StockInPieceListForm> {
  final List<StockInPieceEntry> _pieces = [StockInPieceEntry()];

  @override
  void dispose() {
    for (final piece in _pieces) {
      piece.dispose();
    }
    super.dispose();
  }

  List<StockInPieceEntry> get pieces => _pieces;

  void addPiece() {
    setState(() => _pieces.add(StockInPieceEntry()));
  }

  void removePiece(int index) {
    if (_pieces.length <= 1) return;
    setState(() {
      _pieces[index].dispose();
      _pieces.removeAt(index);
    });
  }

  double? _calculatedSell(int index) {
    if (!widget.showMeasurements) return null;
    final rate = widget.businessDetail?.pricePerMeasurementUnit;
    if (rate == null || rate <= 0) return null;
    final length = double.tryParse(_pieces[index].lengthController.text.trim());
    final width = double.tryParse(_pieces[index].widthController.text.trim());
    if (length == null || width == null) return null;
    return CalculationFormula.clothingPieceSellBase(
      length: length,
      width: width,
      pricePerMeasurementUnit: rate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = UIController.instance.accentColor();
    final unit = widget.businessDetail?.measurementUnit ?? 'ft';
    final rate = widget.businessDetail?.pricePerMeasurementUnit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showMeasurements && rate != null) ...[
          Container(
            padding: const EdgeInsets.all(UIConstants.mediumSpace),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: UIConstants.mediumBorderRadius,
              border: Border.all(color: accent.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Pricing: ${rate.toStringAsFixed(0)} MMK per $unit² — enter length × width per piece',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: UIConstants.mediumSpace),
        ],
        ...List.generate(_pieces.length, (index) {
          final sellPreview = _calculatedSell(index);
          return Container(
            margin: const EdgeInsets.only(bottom: UIConstants.mediumSpace),
            padding: const EdgeInsets.all(UIConstants.mediumSpace),
            decoration: BoxDecoration(
              borderRadius: UIConstants.mediumBorderRadius,
              border: Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Piece ${index + 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: accent,
                          ),
                    ),
                    const Spacer(),
                    if (widget.allowMultiplePieces && _pieces.length > 1)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => removePiece(index),
                        tooltip: 'Remove piece',
                      ),
                  ],
                ),
                if (widget.showMeasurements) ...[
                  const SizedBox(height: UIConstants.smallSpace),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 400;
                      final lengthField = CusTextFieldLogin(
                        txtController: _pieces[index].lengthController,
                        verticalPadding: UIConstants.mediumSpace,
                        horizontalPadding: UIConstants.mediumSpace,
                        hintTxt: 'Length ($unit)',
                        txtInputType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      );
                      final widthField = CusTextFieldLogin(
                        txtController: _pieces[index].widthController,
                        verticalPadding: UIConstants.mediumSpace,
                        horizontalPadding: UIConstants.mediumSpace,
                        hintTxt: 'Width ($unit)',
                        txtInputType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      );
                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(child: lengthField),
                            const SizedBox(width: UIConstants.mediumSpace),
                            Expanded(child: widthField),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          lengthField,
                          const SizedBox(height: UIConstants.smallSpace),
                          widthField,
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: UIConstants.smallSpace),
                  CusTextFieldLogin(
                    txtController: _pieces[index].costController,
                    verticalPadding: UIConstants.mediumSpace,
                    horizontalPadding: UIConstants.mediumSpace,
                    hintTxt: 'Purchase cost (MMK, optional)',
                    txtInputType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  if (sellPreview != null) ...[
                    const SizedBox(height: UIConstants.smallSpace),
                    CusTxtWidget(
                      txt:
                          'Calculated sell: ${sellPreview.toStringAsFixed(0)} MMK (+ tax)',
                      txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                    ),
                  ],
                ],
                if (widget.showBatchNumber) ...[
                  const SizedBox(height: UIConstants.smallSpace),
                  CusTextFieldLogin(
                    txtController: _pieces[index].batchController,
                    verticalPadding: UIConstants.mediumSpace,
                    horizontalPadding: UIConstants.mediumSpace,
                    hintTxt: 'Batch / lot number',
                    txtInputType: TextInputType.text,
                  ),
                ],
              ],
            ),
          );
        }),
        if (widget.allowMultiplePieces)
          OutlinedButton.icon(
            onPressed: addPiece,
            icon: Icon(Icons.add, color: accent),
            label: Text(
              widget.showMeasurements
                  ? 'Add piece (different size)'
                  : 'Add another unit',
            ),
          ),
      ],
    );
  }
}
