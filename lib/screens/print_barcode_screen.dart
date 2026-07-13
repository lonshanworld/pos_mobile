import 'package:barcode/barcode.dart' as barcode_lib;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import '../blocs/loading_bloc/loading_cubit.dart';
import '../blocs/item_bloc/item_cubit.dart';
import '../constants/business_hierarchy_config.dart';
import '../constants/enums.dart';
import '../controller/DB_helper.dart';
import '../controller/ui_controller.dart';
import '../models/item_model_folder/item_model.dart';
import '../models/item_model_folder/uniqueItem_model.dart';
import 'barcode_scanner_screen.dart';

class PrintBarcodeScreen extends StatefulWidget {
  static const routeName = '/print-barcode';

  const PrintBarcodeScreen({super.key});

  @override
  State<PrintBarcodeScreen> createState() => _PrintBarcodeScreenState();
}

class _PrintBarcodeScreenState extends State<PrintBarcodeScreen> {
  final _searchController = TextEditingController();
  final _printKey = GlobalKey();
  bool _uniqueItems = false;
  bool _printImei = false;
  bool _isCapturingBarcode = false;
  int? _selectedCategoryId;
  int? _selectedGroupId;
  int? _selectedTypeId;
  final Set<String> _selected = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _code(ItemModel item) => item.code?.trim().isNotEmpty == true
      ? item.code!.trim()
      : 'ITEM-${item.id}';

  String _uniqueCode(UniqueItemModel item) =>
      item.code?.trim().isNotEmpty == true
      ? item.code!.trim()
      : 'UNIT-${item.id}';

  bool get _isPhoneBusiness =>
      UIController.instance.businessType == BusinessType.phoneLaptopTablets;

  String _printValue(UniqueItemModel item) =>
      _printImei && item.instanceImei?.trim().isNotEmpty == true
      ? item.instanceImei!.trim()
      : _uniqueCode(item);

  bool _hasItemBarcode(ItemModel item) => item.code?.trim().isNotEmpty == true;

  bool _hasUniqueBarcode(UniqueItemModel item) =>
      item.code?.trim().isNotEmpty == true;

  Future<String> _nextAvailableBarcode(String prefix, int id) async {
    var attempt = 0;
    while (true) {
      final suffix = attempt == 0 ? '' : '-$attempt';
      final candidate = '$prefix$id$suffix';
      if (await DBHelper.isBarcodeAvailable(candidate)) return candidate;
      attempt++;
    }
  }

  Widget _buildFilterDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int?>> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  String _catalogName(Map<int, String> names, int? id, String fallback) =>
      id == null ? fallback : names[id] ?? fallback;

  String _hierarchyText({
    required ItemModel item,
    required Map<int, String> categoryNames,
    required Map<int, String> groupNames,
    required Map<int, String> typeNames,
  }) {
    return 'Type: ${_catalogName(typeNames, item.typeId, 'Unknown')}  |  '
        'Group: ${_catalogName(groupNames, item.groupId, 'Unknown')}  |  '
        'Category: ${_catalogName(categoryNames, item.categoryId, 'Unknown')}';
  }

  Widget _buildUniqueItemGroup({
    required ItemModel item,
    required List<UniqueItemModel> uniqueItems,
    required Map<int, String> categoryNames,
    required Map<int, String> groupNames,
    required Map<int, String> typeNames,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(item.name),
        subtitle: Text(
          _hierarchyText(
            item: item,
            categoryNames: categoryNames,
            groupNames: groupNames,
            typeNames: typeNames,
          ),
        ),
        children: uniqueItems.map((uniqueItem) {
          final code = _printValue(uniqueItem);
          final hasBarcode = _hasUniqueBarcode(uniqueItem);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: hasBarcode
                  ? Border.all(color: Colors.green, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CheckboxListTile(
              value: _selected.contains(code),
              title: Text(code),
              subtitle: Text(
                hasBarcode
                    ? 'Barcode: ${uniqueItem.code!.trim()}'
                    : 'Barcode not generated',
                style: TextStyle(
                  color: hasBarcode ? Colors.green : Colors.grey,
                ),
              ),
              secondary: const Icon(Icons.qr_code_2),
              onChanged: (_) => setState(
                () => _selected.contains(code)
                    ? _selected.remove(code)
                    : _selected.add(code),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _generate() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one barcode to generate.'),
        ),
      );
      return;
    }

    final itemCubit = context.read<ItemCubit>();
    final itemState = itemCubit.state;
    var generatedCount = 0;
    final loading = context.read<LoadingCubit>();
    loading.setLoading('Generating barcodes ...');

    if (_uniqueItems) {
      for (final uniqueItem in itemState.activeUniqueItemList) {
        final selected =
            _selected.contains(_printValue(uniqueItem)) ||
            _selected.contains(_uniqueCode(uniqueItem));
        if (selected && !_hasUniqueBarcode(uniqueItem)) {
          final barcode = await _nextAvailableBarcode('UNIT-', uniqueItem.id);
          final success = await DBHelper.updateUniqueItemBarcode(
            uniqueItemId: uniqueItem.id,
            barcode: barcode,
          );
          if (success) generatedCount++;
        }
      }
    } else {
      for (final item in itemState.activeItemList) {
        if (_selected.contains(_code(item)) && !_hasItemBarcode(item)) {
          final barcode = await _nextAvailableBarcode('ITEM-', item.id);
          final success = await DBHelper.updateItemBarcode(
            itemId: item.id,
            barcode: barcode,
          );
          if (success) generatedCount++;
        }
      }
    }

    await itemCubit.reloadAllItem();
    if (!mounted) return;
    if (generatedCount == 0) {
      loading.setFail('Selected items already have barcodes.');
    } else {
      loading.setSuccess('Generated $generatedCount barcode(s).');
    }
  }

  Future<void> _addBarcode() async {
    if (_selected.length != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select exactly one item to add a barcode.'),
        ),
      );
      return;
    }

    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || scanned == null || scanned.trim().isEmpty) return;

    final barcode = scanned.trim();
    final itemCubit = context.read<ItemCubit>();
    final itemState = itemCubit.state;
    final loading = context.read<LoadingCubit>();
    loading.setLoading('Saving barcode ...');

    bool success = false;
    String? previousSelection;
    if (_uniqueItems) {
      for (final uniqueItem in itemState.activeUniqueItemList) {
        final selectionKey = _printValue(uniqueItem);
        if (_selected.contains(selectionKey) ||
            _selected.contains(_uniqueCode(uniqueItem))) {
          previousSelection = selectionKey;
          success = await DBHelper.updateUniqueItemBarcode(
            uniqueItemId: uniqueItem.id,
            barcode: barcode,
          );
          break;
        }
      }
    } else {
      for (final item in itemState.activeItemList) {
        if (_selected.contains(_code(item))) {
          previousSelection = _code(item);
          success = await DBHelper.updateItemBarcode(
            itemId: item.id,
            barcode: barcode,
          );
          break;
        }
      }
    }

    if (success) {
      await itemCubit.reloadAllItem();
    }
    if (!mounted) return;

    if (success) {
      setState(() {
        if (previousSelection != null && !_printImei) {
          _selected
            ..remove(previousSelection)
            ..add(barcode);
        }
      });
      loading.setSuccess('Barcode added.');
    } else {
      loading.setFail('Barcode already exists or could not be saved.');
    }
  }

  Future<void> _print() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one barcode to print.')),
      );
      return;
    }
    final itemState = context.read<ItemCubit>().state;
    final hasMissingBarcode = _uniqueItems
        ? itemState.activeUniqueItemList.any(
            (item) =>
                (_selected.contains(_printValue(item)) ||
                    _selected.contains(_uniqueCode(item))) &&
                !_hasUniqueBarcode(item),
          )
        : itemState.activeItemList.any(
            (item) => _selected.contains(_code(item)) && !_hasItemBarcode(item),
          );
    if (hasMissingBarcode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generate the missing barcode(s) before printing.'),
        ),
      );
      return;
    }

    final printer = context.read<BluetoothPrinterCubit>();
    if (printer.state.bluetoothConnection != BluetoothConnection.connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect a Bluetooth printer in Settings.'),
        ),
      );
      return;
    }
    final loading = context.read<LoadingCubit>();
    loading.setLoading('Printing barcodes ...');
    setState(() {
      _isCapturingBarcode = true;
    });

    bool success = false;
    try {
      // Keep the loading popup open while the fully visible barcode sheet
      // gets a settled paint pass for image capture.
      await WidgetsBinding.instance.endOfFrame;
      success = await printer.printVoucher(_printKey);
    } catch (error) {
      debugPrint('PrintBarcodeScreen: barcode capture failed: $error');
    }

    if (!mounted) return;
    setState(() {
      _isCapturingBarcode = false;
    });
    if (success) {
      loading.setSuccess('Barcode labels sent to printer.');
    } else {
      loading.setFail('Barcode printing failed.');
    }
  }

  Widget _label({required String name, required String code, String? imei}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(height: 72, width: 260, child: _BarcodePainter(code: code)),
          Text(code, style: const TextStyle(color: Colors.black, fontSize: 11)),
          if (imei != null && imei.isNotEmpty)
            Text(
              'IMEI: $imei',
              style: const TextStyle(color: Colors.black, fontSize: 11),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemState = context.watch<ItemCubit>().state;
    final query = _searchController.text.trim().toLowerCase();
    final categoryNames = {
      for (final category in itemState.allActiveCategoryList)
        category.id: category.name,
    };
    final groupNames = {
      for (final group in itemState.allActiveGroupList) group.id: group.name,
    };
    final typeNames = {
      for (final type in itemState.allActiveTypeList) type.id: type.name,
    };
    final itemById = {
      for (final item in itemState.activeItemList) item.id: item,
    };
    final items = itemState.activeItemList.where((e) {
      if (_selectedCategoryId != null && e.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_selectedGroupId != null && e.groupId != _selectedGroupId) {
        return false;
      }
      if (_selectedTypeId != null && e.typeId != _selectedTypeId) {
        return false;
      }
      if (query.isEmpty) return true;
      return e.name.toLowerCase().contains(query) ||
          _code(e).toLowerCase().contains(query) ||
          _hierarchyText(
            item: e,
            categoryNames: categoryNames,
            groupNames: groupNames,
            typeNames: typeNames,
          ).toLowerCase().contains(query);
    }).toList();
    final uniqueItems = itemState.activeUniqueItemList.where((e) {
      if (_printImei && e.instanceImei?.trim().isNotEmpty != true) {
        return false;
      }
      final item = itemById[e.itemId];
      if (item == null) return false;
      if (_selectedCategoryId != null &&
          item.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_selectedGroupId != null && item.groupId != _selectedGroupId) {
        return false;
      }
      if (_selectedTypeId != null && item.typeId != _selectedTypeId) {
        return false;
      }
      final name = item.name;
      return name.toLowerCase().contains(query) ||
          _uniqueCode(e).toLowerCase().contains(query) ||
          (e.instanceImei?.toLowerCase().contains(query) ?? false) ||
          _hierarchyText(
            item: item,
            categoryNames: categoryNames,
            groupNames: groupNames,
            typeNames: typeNames,
          ).toLowerCase().contains(query);
    }).toList();
    final uniqueItemGroups = <int, List<UniqueItemModel>>{};
    for (final uniqueItem in uniqueItems) {
      uniqueItemGroups.putIfAbsent(uniqueItem.itemId, () => []).add(uniqueItem);
    }

    final businessType = UIController.instance.businessType;
    final categoryLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.category,
    );
    final categoryPluralLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.category,
    );
    final groupLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.group,
    );
    final groupPluralLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.group,
    );
    final typeLabel = BusinessHierarchyConfig.getLabel(
      businessType,
      HierarchyLevel.type,
    );
    final typePluralLabel = BusinessHierarchyConfig.getPluralLabel(
      businessType,
      HierarchyLevel.type,
    );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search item or code',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        label: categoryLabel,
                        value: _selectedCategoryId,
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All $categoryPluralLabel'),
                          ),
                          ...itemState.allActiveCategoryList.map(
                            (category) => DropdownMenuItem<int?>(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() {
                          _selectedCategoryId = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: groupLabel,
                        value: _selectedGroupId,
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All $groupPluralLabel'),
                          ),
                          ...itemState.allActiveGroupList.map(
                            (group) => DropdownMenuItem<int?>(
                              value: group.id,
                              child: Text(group.name),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() {
                          _selectedGroupId = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterDropdown(
                        label: typeLabel,
                        value: _selectedTypeId,
                        items: [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All $typePluralLabel'),
                          ),
                          ...itemState.allActiveTypeList.map(
                            (type) => DropdownMenuItem<int?>(
                              value: type.id,
                              child: Text(type.name),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() {
                          _selectedTypeId = value;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: TextButton.icon(
                    onPressed:
                        _selectedCategoryId != null ||
                            _selectedGroupId != null ||
                            _selectedTypeId != null ||
                            _searchController.text.isNotEmpty
                        ? () => setState(() {
                            _selectedCategoryId = null;
                            _selectedGroupId = null;
                            _selectedTypeId = null;
                            _searchController.clear();
                          })
                        : null,
                    icon: const Icon(Icons.filter_alt_off),
                    label: const Text('Clear filters'),
                  ),
                ),
              ),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Items')),
                  ButtonSegment(value: true, label: Text('Unique items')),
                ],
                selected: {_uniqueItems},
                onSelectionChanged: (v) => setState(() {
                  _uniqueItems = v.first;
                  if (!_uniqueItems) _printImei = false;
                  _selected.clear();
                }),
              ),
              if (_isPhoneBusiness && _uniqueItems)
                SwitchListTile.adaptive(
                  title: const Text('Print IMEI labels'),
                  subtitle: const Text(
                    'Use each phone/tablet/laptop IMEI as the barcode value',
                  ),
                  value: _printImei,
                  onChanged: (value) => setState(() {
                    _printImei = value;
                    _selected.clear();
                  }),
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: _uniqueItems
                      ? uniqueItemGroups.length
                      : items.length,
                  itemBuilder: (context, index) {
                    if (!_uniqueItems) {
                      final item = items[index];
                      final code = _code(item);
                      final hasBarcode = _hasItemBarcode(item);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: hasBarcode
                              ? Border.all(color: Colors.green, width: 1.5)
                              : null,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CheckboxListTile(
                          value: _selected.contains(code),
                          title: Text(item.name),
                          subtitle: Text(
                            '${_hierarchyText(item: item, categoryNames: categoryNames, groupNames: groupNames, typeNames: typeNames)}\n${hasBarcode ? 'Barcode: ${item.code!.trim()}' : 'Barcode not generated'}',
                            style: TextStyle(
                              color: hasBarcode ? Colors.green : Colors.grey,
                            ),
                          ),
                          secondary: const Icon(Icons.qr_code_2),
                          onChanged: (_) => setState(
                            () => _selected.contains(code)
                                ? _selected.remove(code)
                                : _selected.add(code),
                          ),
                        ),
                      );
                    }

                    final itemGroups = uniqueItemGroups.entries.toList();
                    final item = itemById[itemGroups[index].key]!;
                    return _buildUniqueItemGroup(
                      item: item,
                      uniqueItems: itemGroups[index].value,
                      categoryNames: categoryNames,
                      groupNames: groupNames,
                      typeNames: typeNames,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addBarcode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Add barcode'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _generate,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate barcode'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _print,
                        icon: const Icon(Icons.print),
                        label: const Text('Print barcode'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IgnorePointer(
              child: Opacity(
                opacity: _isCapturingBarcode ? 1 : 0,
                child: RepaintBoundary(
                  key: _printKey,
                  child: _buildPrintSheet(
                    itemState.activeItemList,
                    itemState.activeUniqueItemList,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintSheet(
    List<ItemModel> items,
    List<UniqueItemModel> uniqueItems,
  ) {
    final itemByCode = {for (final item in items) _code(item): item};
    final uniqueByCode = {
      for (final item in uniqueItems) _printValue(item): item,
    };
    final labels = _selected.map((code) {
      if (_uniqueItems) {
        final unit = uniqueByCode[code]!;
        return _label(
          name: context.read<ItemCubit>().getItem(unit.itemId)?.name ?? 'Item',
          code: code,
          imei: _printImei ? unit.instanceImei : null,
        );
      }
      return _label(name: itemByCode[code]?.name ?? 'Item', code: code);
    }).toList();
    return Material(
      color: Colors.white,
      child: SizedBox(
        width: 384,
        child: Column(mainAxisSize: MainAxisSize.min, children: labels),
      ),
    );
  }
}

class _BarcodePainter extends StatelessWidget {
  final String code;
  const _BarcodePainter({required this.code});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BarcodeCustomPainter(code),
    size: const Size(double.infinity, 72),
  );
}

class _BarcodeCustomPainter extends CustomPainter {
  final String code;
  _BarcodeCustomPainter(this.code);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final generator = barcode_lib.Barcode.code128();
    for (final element in generator.make(
      code,
      width: size.width,
      height: size.height,
    )) {
      if (element is barcode_lib.BarcodeBar && element.black) {
        canvas.drawRect(
          Rect.fromLTWH(
            element.left,
            element.top,
            element.width,
            element.height,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodeCustomPainter oldDelegate) =>
      oldDelegate.code != code;
}
