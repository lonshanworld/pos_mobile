import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:pos_mobile/screens/barcode_scanner_screen.dart'
    as pos_mobile_scanner;
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

class BusinessItemDetailForm extends StatefulWidget {
  final BusinessType businessType;
  final ItemBusinessDetailModel? initialDetail;
  final int? itemId;
  final String? initialBarcode;

  const BusinessItemDetailForm({
    super.key,
    required this.businessType,
    this.initialDetail,
    this.itemId,
    this.initialBarcode,
  });

  @override
  State<BusinessItemDetailForm> createState() => BusinessItemDetailFormState();
}

class BusinessItemDetailFormState extends State<BusinessItemDetailForm> {
  final _clothingColor = TextEditingController();
  final _measurementLength = TextEditingController();
  final _measurementWidth = TextEditingController();
  final _pricePerUnit = TextEditingController();
  final _brand = TextEditingController();
  final _deviceColor = TextEditingController();
  final _ram = TextEditingController();
  final _rom = TextEditingController();
  final _modelNumber = TextEditingController();
  final _weightValue = TextEditingController();
  final _packSize = TextEditingController();
  final _barcode = TextEditingController();
  final _shelfLifeDays = TextEditingController();
  final _dosage = TextEditingController();
  final _activeIngredient = TextEditingController();
  final _manufacturer = TextEditingController();

  String _measurementUnit = 'ft';
  String _weightUnit = 'kg';
  String _sellingUnit = 'per pill';
  bool _isOrganic = false;

  @override
  void initState() {
    super.initState();
    _barcode.text = widget.initialBarcode ?? '';
    final d = widget.initialDetail;
    if (d == null) return;
    _clothingColor.text = d.clothingColor ?? '';
    _measurementLength.text = d.measurementLength?.toString() ?? '';
    _measurementWidth.text = d.measurementWidth?.toString() ?? '';
    _pricePerUnit.text = d.pricePerMeasurementUnit?.toString() ?? '';
    _brand.text = d.brand ?? '';
    _deviceColor.text = d.deviceColor ?? '';
    _ram.text = d.ram ?? '';
    _rom.text = d.rom ?? '';
    _modelNumber.text = d.modelNumber ?? '';
    _weightValue.text = d.weightValue?.toString() ?? '';
    _packSize.text = d.packSize ?? '';
    _shelfLifeDays.text = d.shelfLifeDays?.toString() ?? '';
    _dosage.text = d.dosage ?? '';
    _activeIngredient.text = d.activeIngredient ?? '';
    _manufacturer.text = d.manufacturer ?? '';
    _measurementUnit = d.measurementUnit ?? 'ft';
    _weightUnit = d.weightUnit ?? 'kg';
    _isOrganic = d.isOrganic;
    if (widget.businessType == BusinessType.basicPharmacy) {
      _sellingUnit = d.measurementUnit ?? 'per pill';
    }
  }

  @override
  void dispose() {
    _clothingColor.dispose();
    _measurementLength.dispose();
    _measurementWidth.dispose();
    _pricePerUnit.dispose();
    _brand.dispose();
    _deviceColor.dispose();
    _ram.dispose();
    _rom.dispose();
    _modelNumber.dispose();
    _weightValue.dispose();
    _packSize.dispose();
    _barcode.dispose();
    _shelfLifeDays.dispose();
    _dosage.dispose();
    _activeIngredient.dispose();
    _manufacturer.dispose();
    super.dispose();
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  String? _parseString(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _measurementBasedTotalPrice() {
    final length = _parseDouble(_measurementLength.text);
    final width = _parseDouble(_measurementWidth.text);
    final pricePerUnit = _parseDouble(_pricePerUnit.text);
    if (length == null ||
        width == null ||
        pricePerUnit == null ||
        length <= 0 ||
        width <= 0 ||
        pricePerUnit <= 0) {
      return null;
    }
    return CalculationFormula.clothingPieceSellBase(
      length: length,
      width: width,
      pricePerMeasurementUnit: pricePerUnit,
    );
  }

  Widget _measurementPricingPreview() {
    final accent = UIController.instance.accentColor();
    return ListenableBuilder(
      listenable: Listenable.merge([
        _measurementLength,
        _measurementWidth,
        _pricePerUnit,
      ]),
      builder: (context, child) {
        final totalPrice = _measurementBasedTotalPrice();
        final length = _parseDouble(_measurementLength.text);
        final width = _parseDouble(_measurementWidth.text);
        final area = (length ?? 0) * (width ?? 0);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: UIConstants.mediumSpace),
          padding: const EdgeInsets.all(UIConstants.mediumSpace),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: UIConstants.mediumBorderRadius,
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CusTxtWidget(
                txt: 'Calculated total price preview',
                txtStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700),
              ),
              // const SizedBox(height: UIConstants.smallSpace),
              // CusTxtWidget(
              //   txt:
              //       'UI only. This calculation is not saved to the item or database.',
              //   txtStyle: Theme.of(
              //     context,
              //   ).textTheme.bodySmall!.copyWith(color: Colors.grey.shade700),
              // ),
              const SizedBox(height: UIConstants.smallSpace),
              CusTxtWidget(
                txt: totalPrice == null
                    ? 'Enter length, width, and price per square unit to preview the total.'
                    : 'Area: ${area.toStringAsFixed(2)} $_measurementUnit^2   Total: ${totalPrice.toStringAsFixed(2)} MMK',
                txtStyle: Theme.of(context).textTheme.bodyMedium!,
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _groceryPricingPreview() {
  //   final accent = UIController.instance.accentColor();
  //   return ListenableBuilder(
  //     listenable: Listenable.merge([
  //       _weightValue,
  //       _pricePerUnit,
  //     ]),
  //     builder: (context, child) {
  //       final weight = _parseDouble(_weightValue.text);
  //       final pricePerUnit = _parseDouble(_pricePerUnit.text);
  //       final totalPrice =
  //           (weight ?? 0) > 0 && (pricePerUnit ?? 0) > 0
  //               ? weight! * pricePerUnit!
  //               : null;

  //       return Container(
  //         width: double.infinity,
  //         margin: const EdgeInsets.only(bottom: UIConstants.mediumSpace),
  //         padding: const EdgeInsets.all(UIConstants.mediumSpace),
  //         decoration: BoxDecoration(
  //           color: accent.withValues(alpha: 0.08),
  //           borderRadius: UIConstants.mediumBorderRadius,
  //           border: Border.all(color: accent.withValues(alpha: 0.25)),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             CusTxtWidget(
  //               txt: 'Calculated total price preview',
  //               txtStyle: Theme.of(context)
  //                   .textTheme
  //                   .bodyMedium!
  //                   .copyWith(fontWeight: FontWeight.w700),
  //             ),
  //             const SizedBox(height: UIConstants.smallSpace),
  //             CusTxtWidget(
  //               txt: totalPrice == null
  //                   ? 'Enter weight/volume and price per unit to preview the total.'
  //                   : '${weight!.toStringAsFixed(2)} $_weightUnit × '
  //                       '${pricePerUnit!.toStringAsFixed(0)} MMK/$_weightUnit = '
  //                       '${totalPrice.toStringAsFixed(0)} MMK',
  //               txtStyle: Theme.of(context).textTheme.bodyMedium!,
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  ItemBusinessDetailModel buildDetail(int itemId) {
    return ItemBusinessDetailModel(
      id: widget.initialDetail?.id,
      itemId: itemId,
      clothingColor: _parseString(_clothingColor.text),
      measurementLength: _parseDouble(_measurementLength.text),
      measurementWidth: _parseDouble(_measurementWidth.text),
      pricePerMeasurementUnit: _parseDouble(_pricePerUnit.text),
      brand: _parseString(_brand.text),
      deviceCategory: null,
      deviceColor: _parseString(_deviceColor.text),
      ram: _parseString(_ram.text),
      rom: _parseString(_rom.text),
      modelNumber: _parseString(_modelNumber.text),
      weightValue: _parseDouble(_weightValue.text),
      weightUnit: _weightUnit,
      packSize: _parseString(_packSize.text),
      isOrganic: _isOrganic,
      shelfLifeDays: _parseInt(_shelfLifeDays.text),
      dosage: _parseString(_dosage.text),
      activeIngredient: _parseString(_activeIngredient.text),
      manufacturer: _parseString(_manufacturer.text),
      measurementUnit: widget.businessType == BusinessType.basicPharmacy
          ? _sellingUnit
          : _measurementUnit,
    );
  }

  String? buildItemBarcode() => _parseString(_barcode.text);

  String? validate() {
    switch (widget.businessType) {
      case BusinessType.clothing:
        final rate = _parseDouble(_pricePerUnit.text);
        if (rate == null || rate <= 0) {
          return 'Enter price per measurement unit (required for clothing pricing)';
        }
        return null;
      case BusinessType.electronics:
        return null;
      case BusinessType.convenience:
        return null;
      case BusinessType.basicPharmacy:
        // if (_parseString(_dosage.text) == null) {
        //   return 'Enter dosage (required for pharmacy items)';
        // }
        return null;
      case BusinessType.grocery:
      case BusinessType.food:
      case BusinessType.general:
        return null;
      case BusinessType.phoneLaptopTablets:
        // if (_parseString(_brand.text) == null) {
        //   return 'Enter brand (required for phone / laptop / tablet items)';
        // }
        return null;
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType keyboard = TextInputType.text,
    String? hint,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.mediumSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CusTxtWidget(
            txt: label,
            txtStyle: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: UIConstants.smallSpace),
          CusTextFieldLogin(
            txtController: controller,
            verticalPadding: UIConstants.mediumSpace,
            horizontalPadding: UIConstants.bigSpace,
            hintTxt: hint ?? label,
            txtInputType: keyboard,
            suffixIcon: suffixIcon,
          ),
        ],
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> options,
    required String Function(T) labelBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.mediumSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CusTxtWidget(
            txt: label,
            txtStyle: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: UIConstants.smallSpace),
          DropdownButtonFormField<T>(
            initialValue: value,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderRadius: UIConstants.mediumBorderRadius,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: UIConstants.bigSpace,
                vertical: UIConstants.mediumSpace,
              ),
            ),
            items: options
                .map(
                  (e) =>
                      DropdownMenuItem(value: e, child: Text(labelBuilder(e))),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _itemBarcodeNote() {
    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.mediumSpace),
      child: CusTxtWidget(
        txt:
            'This is not for unique item barcode. This is for item differentiation.',
        txtStyle: Theme.of(
          context,
        ).textTheme.bodySmall!.copyWith(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = UIController.instance.accentColor();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: UIConstants.mediumSpace),
      padding: const EdgeInsets.all(UIConstants.bigSpace),
      decoration: BoxDecoration(
        borderRadius: UIConstants.mediumBorderRadius,
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        color: accent.withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.businessType.icon, color: accent, size: 22),
              const SizedBox(width: UIConstants.mediumSpace),
              Expanded(
                child: Text(
                  '${widget.businessType.displayName} Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.mediumSpace),
          ..._fieldsForType(),
        ],
      ),
    );
  }

  List<Widget> _fieldsForType() {
    switch (widget.businessType) {
      case BusinessType.clothing:
        return [
          CusTxtWidget(
            txt:
                'Reference fields below. Actual piece sizes and prices are set at stock-in.',
            txtStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: UIConstants.smallSpace),
          _field('Color', _clothingColor, hint: 'e.g. Navy Blue'),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Length',
                  _measurementLength,
                  keyboard: TextInputType.number,
                  hint: '3',
                ),
              ),
              const SizedBox(width: UIConstants.mediumSpace),
              Expanded(
                child: _field(
                  'Width',
                  _measurementWidth,
                  keyboard: TextInputType.number,
                  hint: '3',
                ),
              ),
            ],
          ),
          _dropdown<String>(
            label: 'Measurement Unit',
            value: _measurementUnit,
            options: const ['ft', 'm', 'inch'],
            labelBuilder: (v) => v,
            onChanged: (v) => setState(() => _measurementUnit = v ?? 'ft'),
          ),
          _field(
            'Price per square unit (MMK)',
            _pricePerUnit,
            keyboard: const TextInputType.numberWithOptions(decimal: true),
            hint: 'e.g. 2222 per square ft',
          ),
          _measurementPricingPreview(),
          CusTxtWidget(
            txt:
                'Example: 3 ft x 3 ft at 2222 MMK/square ft is about 20,000 MMK sell price',
            txtStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.grey),
          ),
        ];
      case BusinessType.electronics:
        return [
          _field(
            'Barcode / UPC',
            _barcode,
            hint: 'Scan or enter barcode',
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () async {
                final scanned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const pos_mobile_scanner.BarcodeScannerScreen();
                    },
                  ),
                );
                if (scanned != null && scanned is String) {
                  setState(() {
                    _barcode.text = scanned;
                  });
                }
              },
            ),
          ),
          _itemBarcodeNote(),
          _field('Color', _deviceColor, hint: 'e.g. White, Black, Silver'),
          _field('Model Number', _modelNumber, hint: 'Optional model / SKU'),
        ];
      case BusinessType.grocery:
        return [
          _field(
            'Barcode / UPC',
            _barcode,
            hint: 'Scan or enter barcode (Optional)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () async {
                final scanned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const pos_mobile_scanner.BarcodeScannerScreen();
                    },
                  ),
                );
                if (scanned != null && scanned is String) {
                  setState(() {
                    _barcode.text = scanned;
                  });
                }
              },
            ),
          ),
          _itemBarcodeNote(),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _field(
                  'Weight / Volume',
                  _weightValue,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: UIConstants.mediumSpace),
              Expanded(
                child: _dropdown<String>(
                  label: 'Unit',
                  value: _weightUnit,
                  options: const ['kg', 'g', 'L', 'ml'],
                  labelBuilder: (v) => v,
                  onChanged: (v) => setState(() => _weightUnit = v ?? 'kg'),
                ),
              ),
            ],
          ),
          // _field(
          //   'Price per $_weightUnit (MMK)',
          //   _pricePerUnit,
          //   keyboard: const TextInputType.numberWithOptions(decimal: true),
          //   hint: 'e.g. 500 per $_weightUnit',
          // ),
          // _groceryPricingPreview(),
          _field(
            'Shelf Life (days)',
            _shelfLifeDays,
            keyboard: TextInputType.number,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Organic product'),
            value: _isOrganic,
            onChanged: (v) => setState(() => _isOrganic = v),
          ),
        ];
      case BusinessType.convenience:
        return [
          _field(
            'Barcode / UPC',
            _barcode,
            hint: 'Scan or enter barcode (Optional)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () async {
                final scanned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const pos_mobile_scanner.BarcodeScannerScreen();
                    },
                  ),
                );
                if (scanned != null && scanned is String) {
                  setState(() {
                    _barcode.text = scanned;
                  });
                }
              },
            ),
          ),
          _itemBarcodeNote(),
          _field('Pack Size', _packSize, hint: 'e.g. 6-pack, 500ml'),
          // _field('Brand', _brand, hint: 'Optional brand name'),
        ];
      case BusinessType.basicPharmacy:
        return [
          _field(
            'Barcode / UPC',
            _barcode,
            hint: 'Scan or enter barcode (Optional)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () async {
                final scanned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const pos_mobile_scanner.BarcodeScannerScreen();
                    },
                  ),
                );
                if (scanned != null && scanned is String) {
                  setState(() {
                    _barcode.text = scanned;
                  });
                }
              },
            ),
          ),
          _itemBarcodeNote(),
          _dropdown<String>(
            label: 'Selling Unit',
            value: _sellingUnit,
            options: const ['per pill', 'per card', 'per small pack'],
            labelBuilder: (v) => v,
            onChanged: (v) => setState(() => _sellingUnit = v ?? 'per pill'),
          ),
          _field('Dosage', _dosage, hint: 'e.g. 500mg tablet'),
          _field(
            'Active Ingredient',
            _activeIngredient,
            hint: 'e.g. Paracetamol',
          ),
        ];
      case BusinessType.phoneLaptopTablets:
        return [
          // _field(
          //   'Barcode / UPC',
          //   _barcode,
          //   hint: 'Scan or enter barcode (Optional)',
          //   suffixIcon: IconButton(
          //     icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
          //     onPressed: () async {
          //       final scanned = await Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) {
          //             return const pos_mobile_scanner.BarcodeScannerScreen();
          //           },
          //         ),
          //       );
          //       if (scanned != null && scanned is String) {
          //         setState(() {
          //           _barcode.text = scanned;
          //         });
          //       }
          //     },
          //   ),
          // ),
          // _itemBarcodeNote(),
          // _field('Brand', _brand, hint: 'e.g. Apple, Samsung'),
          _field('RAM', _ram, hint: 'e.g. 8GB / 16GB'),
          _field('Storage', _rom, hint: 'e.g. 128GB / 512GB SSD'),
          _field('Color', _deviceColor, hint: 'e.g. Midnight Black'),
          _field('Model Number', _modelNumber, hint: 'Optional SKU / model'),
        ];
      case BusinessType.food:
        return [
          // _field('Cuisine Type', _brand, hint: 'e.g. Italian, Thai, Bakery'),
          _field(
            'Allergen Info',
            _activeIngredient,
            hint: 'e.g. Contains nuts, Dairy-free',
          ),
          _field(
            'Prep Time (mins)',
            _shelfLifeDays,
            keyboard: TextInputType.number,
            hint: 'e.g. 15',
          ),
        ];
      case BusinessType.general:
        return [
          _field(
            'Barcode / UPC',
            _barcode,
            hint: 'Scan or enter barcode (Optional)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
              onPressed: () async {
                final scanned = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const pos_mobile_scanner.BarcodeScannerScreen();
                    },
                  ),
                );
                if (scanned != null && scanned is String) {
                  setState(() {
                    _barcode.text = scanned;
                  });
                }
              },
            ),
          ),
          _itemBarcodeNote(),
        ];
    }
  }
}
