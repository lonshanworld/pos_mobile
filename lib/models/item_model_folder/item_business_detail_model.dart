import 'package:pos_mobile/constants/enums.dart';

class ItemBusinessDetailModel {
  final int? id;
  final int itemId;
  final String? clothingColor;
  final double? measurementLength;
  final double? measurementWidth;
  final String? measurementUnit;
  final double? pricePerMeasurementUnit;
  final String? brand;
  final String? deviceCategory;
  final String? deviceColor;
  final String? ram;
  final String? rom;
  final String? modelNumber;
  final double? weightValue;
  final String? weightUnit;
  final String? packSize;
  final String? barcode;
  final bool isOrganic;
  final int? shelfLifeDays;
  final String? dosage;
  final String? activeIngredient;
  final String? manufacturer;

  const ItemBusinessDetailModel({
    this.id,
    required this.itemId,
    this.clothingColor,
    this.measurementLength,
    this.measurementWidth,
    this.measurementUnit,
    this.pricePerMeasurementUnit,
    this.brand,
    this.deviceCategory,
    this.deviceColor,
    this.ram,
    this.rom,
    this.modelNumber,
    this.weightValue,
    this.weightUnit,
    this.packSize,
    this.barcode,
    this.isOrganic = false,
    this.shelfLifeDays,
    this.dosage,
    this.activeIngredient,
    this.manufacturer,
  });

  bool get isEmpty {
    return clothingColor == null &&
        measurementLength == null &&
        measurementWidth == null &&
        measurementUnit == null &&
        pricePerMeasurementUnit == null &&
        brand == null &&
        deviceCategory == null &&
        deviceColor == null &&
        ram == null &&
        rom == null &&
        modelNumber == null &&
        weightValue == null &&
        weightUnit == null &&
        packSize == null &&
        barcode == null &&
        !isOrganic &&
        shelfLifeDays == null &&
        dosage == null &&
        activeIngredient == null &&
        manufacturer == null;
  }

  ItemBusinessDetailModel copyWith({int? id, int? itemId}) {
    return ItemBusinessDetailModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      clothingColor: clothingColor,
      measurementLength: measurementLength,
      measurementWidth: measurementWidth,
      measurementUnit: measurementUnit,
      pricePerMeasurementUnit: pricePerMeasurementUnit,
      brand: brand,
      deviceCategory: deviceCategory,
      deviceColor: deviceColor,
      ram: ram,
      rom: rom,
      modelNumber: modelNumber,
      weightValue: weightValue,
      weightUnit: weightUnit,
      packSize: packSize,
      barcode: barcode,
      isOrganic: isOrganic,
      shelfLifeDays: shelfLifeDays,
      dosage: dosage,
      activeIngredient: activeIngredient,
      manufacturer: manufacturer,
    );
  }

  factory ItemBusinessDetailModel.fromJson(Map<String, dynamic> json) {
    return ItemBusinessDetailModel(
      id: json['id'] as int?,
      itemId: json['itemId'] as int,
      clothingColor: json['clothingColor'] as String?,
      measurementLength: (json['measurementLength'] as num?)?.toDouble(),
      measurementWidth: (json['measurementWidth'] as num?)?.toDouble(),
      measurementUnit: json['measurementUnit'] as String?,
      pricePerMeasurementUnit: (json['pricePerMeasurementUnit'] as num?)?.toDouble(),
      brand: json['brand'] as String?,
      deviceCategory: json['deviceCategory'] as String?,
      deviceColor: json['deviceColor'] as String?,
      ram: json['ram'] as String?,
      rom: json['rom'] as String?,
      modelNumber: json['modelNumber'] as String?,
      weightValue: (json['weightValue'] as num?)?.toDouble(),
      weightUnit: json['weightUnit'] as String?,
      packSize: json['packSize'] as String?,
      barcode: json['barcode'] as String?,
      isOrganic: json['isOrganic'] == 1,
      shelfLifeDays: json['shelfLifeDays'] as int?,
      dosage: json['dosage'] as String?,
      activeIngredient: json['activeIngredient'] as String?,
      manufacturer: json['manufacturer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'itemId': itemId,
      'clothingColor': clothingColor,
      'measurementLength': measurementLength,
      'measurementWidth': measurementWidth,
      'measurementUnit': measurementUnit,
      'pricePerMeasurementUnit': pricePerMeasurementUnit,
      'brand': brand,
      'deviceCategory': deviceCategory,
      'deviceColor': deviceColor,
      'ram': ram,
      'rom': rom,
      'modelNumber': modelNumber,
      'weightValue': weightValue,
      'weightUnit': weightUnit,
      'packSize': packSize,
      'barcode': barcode,
      'isOrganic': isOrganic ? 1 : 0,
      'shelfLifeDays': shelfLifeDays,
      'dosage': dosage,
      'activeIngredient': activeIngredient,
      'manufacturer': manufacturer,
    };
  }

  List<String> summaryLines(BusinessType businessType) {
    final lines = <String>[];
    switch (businessType) {
      case BusinessType.clothing:
        if (clothingColor != null && clothingColor!.isNotEmpty) {
          lines.add('Color: $clothingColor');
        }
        if (measurementLength != null && measurementWidth != null) {
          final unit = measurementUnit ?? 'ft';
          lines.add('Size: ${measurementLength}x$measurementWidth $unit');
        }
        if (pricePerMeasurementUnit != null) {
          lines.add('${pricePerMeasurementUnit!.toStringAsFixed(0)} MMK/$measurementUnit²');
        }
      case BusinessType.electronics:
        if (brand != null && brand!.isNotEmpty) lines.add('Brand: $brand');
        if (deviceCategory != null && deviceCategory!.isNotEmpty) {
          lines.add(deviceCategory!);
        }
        if (ram != null && ram!.isNotEmpty) lines.add('RAM: $ram');
        if (rom != null && rom!.isNotEmpty) lines.add('Storage: $rom');
        if (deviceColor != null && deviceColor!.isNotEmpty) {
          lines.add('Color: $deviceColor');
        }
      case BusinessType.grocery:
        if (weightValue != null) {
          lines.add('${weightValue!.toStringAsFixed(2)} ${weightUnit ?? 'kg'}');
        }
        if (isOrganic) lines.add('Organic');
        if (shelfLifeDays != null) lines.add('Shelf life: $shelfLifeDays days');
      case BusinessType.convenience:
        if (barcode != null && barcode!.isNotEmpty) lines.add('Barcode: $barcode');
        if (packSize != null && packSize!.isNotEmpty) lines.add('Pack: $packSize');
      case BusinessType.basicPharmacy:
        if (dosage != null && dosage!.isNotEmpty) lines.add('Dosage: $dosage');
        if (activeIngredient != null && activeIngredient!.isNotEmpty) {
          lines.add(activeIngredient!);
        }
        if (manufacturer != null && manufacturer!.isNotEmpty) {
          lines.add(manufacturer!);
        }
      case BusinessType.phoneLaptopTablets:
        if (modelNumber != null && modelNumber!.isNotEmpty) {
          lines.add('Model: $modelNumber');
        }
      case BusinessType.food:
        if (brand != null && brand!.isNotEmpty) {
          lines.add('Cuisine: $brand');
        }
        if (activeIngredient != null && activeIngredient!.isNotEmpty) {
          lines.add('Allergen: $activeIngredient');
        }
        if (shelfLifeDays != null) {
          lines.add('Prep Time: $shelfLifeDays mins');
        }
      case BusinessType.general:
        break;
    }
    return lines;
  }
}
