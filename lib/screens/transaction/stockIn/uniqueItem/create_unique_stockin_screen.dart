import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/services/pos_repository.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/error_handlers/item_folder/no_selected_id_error_widget.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/stock_in_unit_spec.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/screens/barcode_scanner_screen.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/cus_datepicker_withtxtfield_widget.dart';
import 'package:pos_mobile/widgets/stock_in_unit_fields.dart';
import 'package:pos_mobile/screens/screen_data_loader.dart';

class CreateUniqueStockInScreen extends StatefulWidget {
  final ItemModel itemModel;
  final bool batchStockIn;

  const CreateUniqueStockInScreen({
    super.key,
    required this.itemModel,
    required this.batchStockIn,
  });

  @override
  State<CreateUniqueStockInScreen> createState() =>
      _CreateUniqueStockInScreenState();
}

class _CreateUniqueStockInScreenState extends State<CreateUniqueStockInScreen> {
  final TextEditingController expireDateController = TextEditingController();
  final TextEditingController manufactureDateController =
      TextEditingController();
  final TextEditingController placeController = TextEditingController();
  final TextEditingController pharmacyBatchController = TextEditingController();
  final GlobalKey<StockInPieceListFormState> _pieceFormKey =
      GlobalKey<StockInPieceListFormState>();
  final List<TextEditingController> _unitCodeControllers = [];
  final List<TextEditingController> _imeiControllers = [];
  List<StockInPieceEntry> _pieceEntries = [];

  int moreItem = 0;
  DateTime? expiredDate;
  DateTime? manufactureDate;
  late final Future<_UniqueItemParents?> _parentsFuture;
  ItemBusinessDetailModel? _businessDetail;
  BusinessType? _businessType;

  bool get _isClothing => _businessType == BusinessType.clothing;

  bool get _isPharmacy => _businessType == BusinessType.basicPharmacy;
  bool get _isPhoneTablets => _businessType == BusinessType.phoneLaptopTablets;

  bool get _supportsUniqueCodeForm =>
      _businessType != null &&
      _businessType != BusinessType.clothing &&
      _businessType != BusinessType.food;

  bool get _isMeasurementBasedClothing {
    if (!_isClothing) return false;
    final detail = _businessDetail;
    final length = detail?.measurementLength;
    final width = detail?.measurementWidth;
    final rate = detail?.pricePerMeasurementUnit;
    return length != null &&
        length > 0 &&
        width != null &&
        width > 0 &&
        rate != null &&
        rate > 0;
  }

  bool get _canTrackExpiry =>
      (_businessType?.allowsExpiryTracking ?? true) &&
      widget.itemModel.hasExpire;

  /// Clothing always uses per-piece sizes; pharmacy uses per-piece batch on single stock-in.
  bool get _usesPieceForm =>
      _isMeasurementBasedClothing || (_isPharmacy && !widget.batchStockIn);

  bool get _usesPharmacyPieceForm => _isPharmacy && !widget.batchStockIn;

  List<StockInPieceEntry> get _currentPieceEntries =>
      _pieceFormKey.currentState?.pieces ?? _pieceEntries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _businessType ??= context.read<ShopInfoCubit>().state.businessType;
    if (_supportsUniqueCodeForm &&
        !_usesPieceForm &&
        _unitCodeControllers.isEmpty) {
      _ensureUnitCodeControllers(widget.batchStockIn ? moreItem : 1);
    }
  }

  @override
  void initState() {
    super.initState();
    moreItem = 0;
    unawaited(loadData());
    _parentsFuture = _loadParents();
    _loadBusinessDetail();
  }

  Future<void> loadData() async {
    await Future.wait([
      ScreenDataLoader.items(context),
      ScreenDataLoader.transactions(context),
      ScreenDataLoader.shopInfo(context),
      ScreenDataLoader.users(context),
    ]);
  }

  Future<void> _loadBusinessDetail() async {
    final detail = await PosRepository.instance.fetchBusinessDetail(
      widget.itemModel.id,
    );
    if (mounted) {
      setState(() {
        _businessDetail = detail;
        _applyGroceryShelfLifeDefault(detail);
      });
    }
  }

  void _applyGroceryShelfLifeDefault(ItemBusinessDetailModel? detail) {
    if (_businessType != BusinessType.grocery &&
        _businessType != BusinessType.convenience) {
      return;
    }
    if (!_canTrackExpiry) {
      return;
    }
    final days = detail?.shelfLifeDays;
    if (days == null || days <= 0) {
      return;
    }
    if (expiredDate != null) {
      return;
    }

    expiredDate = DateTime.now().add(Duration(days: days));
    expireDateController.text = TextFormatters.getDate(expiredDate!);
  }

  Future<_UniqueItemParents?> _loadParents() async {
    try {
      final TypeModel? typeModel = await PosRepository.instance.fetchTypeById(
        widget.itemModel.typeId,
      );
      if (typeModel == null) return null;

      final int? resolvedGroupId =
          widget.itemModel.groupId ?? typeModel.groupId;
      final GroupModel? groupModel = resolvedGroupId == null
          ? null
          : await PosRepository.instance.fetchGroupById(resolvedGroupId);

      final int? resolvedCategoryId =
          widget.itemModel.categoryId ?? groupModel?.categoryId;
      final CategoryModel? categoryModel = resolvedCategoryId == null
          ? null
          : await PosRepository.instance.fetchCategoryById(resolvedCategoryId);

      return _UniqueItemParents(
        typeModel: typeModel,
        groupModel: groupModel,
        categoryModel: categoryModel,
      );
    } catch (err, st) {
      debugPrint(
        'CreateUniqueStockInScreen: failed to load parents itemId=${widget.itemModel.id}',
      );
      debugPrint(err.toString());
      debugPrint(st.toString());
      return null;
    }
  }

  @override
  void dispose() {
    expireDateController.dispose();
    manufactureDateController.dispose();
    placeController.dispose();
    pharmacyBatchController.dispose();
    for (final controller in _unitCodeControllers) {
      controller.dispose();
    }
    for (final controller in _imeiControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _ensureUnitCodeControllers(int targetCount) {
    while (_unitCodeControllers.length < targetCount) {
      _unitCodeControllers.add(TextEditingController());
      if (_isPhoneTablets) {
        _imeiControllers.add(TextEditingController());
      }
    }
    while (_unitCodeControllers.length > targetCount) {
      _unitCodeControllers.removeLast().dispose();
      if (_isPhoneTablets && _imeiControllers.isNotEmpty) {
        _imeiControllers.removeLast().dispose();
      }
    }
  }

  Future<void> _scanUniqueCodeInto(TextEditingController controller) async {
    final scanned = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || scanned == null || scanned.trim().isEmpty) return;
    setState(() {
      controller.text = scanned.trim();
    });
  }

  List<StockInUnitSpec>? _buildUnitSpecs() {
    if (_isMeasurementBasedClothing) {
      final pieces = _currentPieceEntries;
      if (pieces.isEmpty) return null;
      final specs = StockInUnitBuilder.fromClothingPieces(
        pieces: pieces,
        itemModel: widget.itemModel,
        businessDetail: _businessDetail,
      );
      if (specs == null || !widget.batchStockIn) return specs;
      return List.generate(specs.length * moreItem, (index) {
        final spec = specs[index % specs.length];
        return StockInUnitSpec(
          instanceLength: spec.instanceLength,
          instanceWidth: spec.instanceWidth,
          instanceBatchNumber: spec.instanceBatchNumber,
          originalPrice: spec.originalPrice,
          profitPrice: spec.profitPrice,
        );
      });
    }

    if (_isPharmacy) {
      // if (widget.batchStockIn) {
      //   final batch = pharmacyBatchController.text.trim();
      //   if (batch.isEmpty) return null;
      //   final specs = StockInUnitBuilder.fromPharmacyBatch(
      //     batchNumber: batch,
      //     count: moreItem,
      //     itemModel: widget.itemModel,
      //   );
      //   return _attachOptionalCodes(specs);
      // }
      if (!widget.batchStockIn) {
        final pieces = _currentPieceEntries;
        if (pieces.isEmpty) return null;
        final specs = StockInUnitBuilder.fromPharmacyPieces(
          pieces: pieces,
          itemModel: widget.itemModel,
        );
        return _attachOptionalCodes(specs);
      }
    }

    if (_supportsUniqueCodeForm) {
      return List.generate(_unitCodeControllers.length, (index) {
        final code = _unitCodeControllers[index].text.trim();
        final imei = _isPhoneTablets && index < _imeiControllers.length
            ? _imeiControllers[index].text.trim()
            : null;
        return StockInUnitSpec(
          code: code.isEmpty ? null : code,
          instanceImei: imei?.isEmpty == true ? null : imei,
        );
      });
    }

    return null;
  }

  List<StockInUnitSpec> _attachOptionalCodes(List<StockInUnitSpec> specs) {
    return List.generate(specs.length, (index) {
      final spec = specs[index];
      final code = index < _unitCodeControllers.length
          ? _unitCodeControllers[index].text.trim()
          : '';
      return StockInUnitSpec(
        code: code.isEmpty ? null : code,
        instanceLength: spec.instanceLength,
        instanceWidth: spec.instanceWidth,
        instanceBatchNumber: spec.instanceBatchNumber,
        originalPrice: spec.originalPrice,
        profitPrice: spec.profitPrice,
      );
    });
  }

  String? _validateBeforeSubmit() {
    if (_canTrackExpiry &&
        expiredDate == null &&
        _businessType != BusinessType.grocery &&
        _businessType != BusinessType.convenience) {
      return 'Please add expired date';
    }

    if (_isMeasurementBasedClothing) {
      final pieces = _currentPieceEntries;
      if (pieces.isEmpty) return 'Add at least one piece';
      for (int i = 0; i < pieces.length; i++) {
        final length = double.tryParse(pieces[i].lengthController.text.trim());
        final width = double.tryParse(pieces[i].widthController.text.trim());
        if (length == null || length <= 0 || width == null || width <= 0) {
          return 'Enter valid length and width for piece ${i + 1}';
        }
      }
      return null;
    }

    if (_usesPharmacyPieceForm) {
      final pieces = _currentPieceEntries;
      if (pieces.isEmpty) return 'Add at least one unit';
      for (int i = 0; i < pieces.length; i++) {
        if (pieces[i].batchController.text.trim().isEmpty) {
          return 'Enter batch number for unit ${i + 1}';
        }
      }
      return null;
    }

    if (_supportsUniqueCodeForm && !_usesPieceForm) {
      if (_unitCodeControllers.isEmpty) {
        return 'Please add stock';
      }
      final seenCodes = <String>{};
      for (int i = 0; i < _unitCodeControllers.length; i++) {
        final code = _unitCodeControllers[i].text.trim();
        if (code.isEmpty) continue;
        final normalized = code.toLowerCase();
        if (!seenCodes.add(normalized)) {
          return 'Duplicate code found for unit ${i + 1}';
        }
      }
    }

    if (widget.batchStockIn && moreItem < 1 && !_usesPieceForm) {
      return 'Please add stock';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<UniqueItemModel> uniqueItemList = context
        .read<ItemCubit>()
        .getSelectedUniqueItemList(widget.itemModel.id);
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context
        .watch<ThemeCubit>()
        .state
        .themeModeType;
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final accent = uiController.accentColor();

    void showValidationMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }

    Future<void> createNewItemList(_UniqueItemParents parents) async {
      final loadingCubit = context.read<LoadingCubit>();
      final transactionsCubit = context.read<TransactionsCubit>();
      final itemCubit = context.read<ItemCubit>();
      final navigator = Navigator.of(context);

      List<StockInUnitSpec>? unitSpecs;
      try {
        unitSpecs = _buildUnitSpecs();
      } on ArgumentError catch (e) {
        showValidationMessage(e.message.toString());
        return;
      } catch (e) {
        showValidationMessage('Error building unit details: $e');
        return;
      }

      if (_isMeasurementBasedClothing &&
          (unitSpecs == null || unitSpecs.isEmpty)) {
        showValidationMessage('Invalid clothing piece measurements.');
        return;
      }

      final seenBarcodes = <String>{};
      for (final spec in unitSpecs ?? const <StockInUnitSpec>[]) {
        final barcode = spec.code?.trim();
        if (barcode == null || barcode.isEmpty) continue;

        if (!seenBarcodes.add(barcode.toLowerCase())) {
          showValidationMessage('Duplicate barcode: $barcode');
          return;
        }

        if (!await PosRepository.instance.isBarcodeAvailable(barcode)) {
          showValidationMessage('Barcode already exists: $barcode');
          return;
        }
      }

      final int itemLength =
          unitSpecs?.length ?? (widget.batchStockIn ? moreItem : 1);

      try {
        loadingCubit.setLoading('Adding ...');

        final value = await transactionsCubit.createNewUniqueItemList(
          userModel: userModel,
          categoryModel: parents.categoryModel,
          groupModel: parents.groupModel,
          typeModel: parents.typeModel,
          itemModel: widget.itemModel,
          code: null,
          itemManufactureDate: _canTrackExpiry ? manufactureDate : null,
          itemExpireDate: _canTrackExpiry ? expiredDate : null,
          getItemFromWhere: placeController.text.trim().isEmpty
              ? null
              : placeController.text.trim(),
          itemLength: itemLength,
          unitSpecs: unitSpecs,
        );

        if (!mounted) return;
        if (value) {
          await itemCubit.reloadAllItem();
          if (!mounted) return;
          // The loading dialog is pushed above this bottom sheet. Clear it
          // first so the following pop dismisses the stock-in screen itself.
          loadingCubit.setSuccess('Success !');
          if (navigator.canPop()) {
            navigator.pop();
          }
        } else {
          loadingCubit.setFail(
            'Stock could not be added. A barcode may already be in use; please use a different barcode.',
          );
        }
      } catch (err, st) {
        debugPrint(
          'CreateUniqueStockInScreen: stock-in failed itemId=${widget.itemModel.id}',
        );
        debugPrint(err.toString());
        debugPrint(st.toString());
        rethrow;
      }
    }

    Widget buildForm(_UniqueItemParents formParents) {
      final pieceCount = _currentPieceEntries.isEmpty
          ? 1
          : _currentPieceEntries.length;
      final expectedCodeCount = _usesPieceForm
          ? pieceCount
          : widget.batchStockIn
          ? moreItem
          : 1;
      if (_supportsUniqueCodeForm) {
        _ensureUnitCodeControllers(expectedCodeCount);
      }
      final addingCount = _usesPieceForm
          ? (_isMeasurementBasedClothing && widget.batchStockIn
                ? pieceCount * moreItem
                : pieceCount)
          : _supportsUniqueCodeForm
          ? _unitCodeControllers.length
          : moreItem;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.bigSpace,
            vertical: UIConstants.mediumSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleSmall!,
                    txt: 'Stock :  ',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: UIConstants.smallSpace,
                      horizontal: UIConstants.mediumSpace,
                    ),
                    decoration: BoxDecoration(
                      color: uiController.getpureOppositeClr(themeModeType),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(UIConstants.smallRadius),
                      ),
                    ),
                    child: CusTxtWidget(
                      txt: uniqueItemList.length.toString(),
                      txtStyle: Theme.of(context).textTheme.titleMedium!
                          .copyWith(
                            color: uiController.getpureDirectClr(themeModeType),
                          ),
                    ),
                  ),
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleMedium!,
                    txt: '  +  $addingCount',
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.mediumSpace),
              if (widget.batchStockIn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CusIconBtn(
                      size: UIConstants.normalBigIconSize,
                      hasBorder: true,
                      func: () {
                        setState(() {
                          if (moreItem < 999) {
                            moreItem++;
                            if (_supportsUniqueCodeForm) {
                              _unitCodeControllers.add(TextEditingController());
                              if (_isPhoneTablets) {
                                _imeiControllers.add(TextEditingController());
                              }
                            }
                          }
                        });
                      },
                      clr: Colors.green,
                      icon: Icons.plus_one,
                    ),
                    uiController.sizedBox(
                      cusHeight: null,
                      cusWidth: UIConstants.bigSpace,
                    ),
                    CusIconBtn(
                      size: UIConstants.normalBigIconSize,
                      hasBorder: true,
                      func: () {
                        setState(() {
                          if (moreItem > 0) {
                            moreItem--;
                            if (_supportsUniqueCodeForm &&
                                _unitCodeControllers.isNotEmpty) {
                              _unitCodeControllers.removeLast().dispose();
                              if (_isPhoneTablets &&
                                  _imeiControllers.isNotEmpty) {
                                _imeiControllers.removeLast().dispose();
                              }
                            }
                          }
                        });
                      },
                      clr: Colors.red,
                      icon: Icons.exposure_minus_1,
                    ),
                  ],
                ),
              // if (_isPharmacy && widget.batchStockIn) ...[
              //   uiController.sizedBox(
              //     cusHeight: UIConstants.mediumSpace,
              //     cusWidth: null,
              //   ),
              //   CusTextFieldLogin(
              //     txtController: pharmacyBatchController,
              //     verticalPadding: UIConstants.mediumSpace,
              //     horizontalPadding: UIConstants.bigSpace,
              //     hintTxt: 'Batch / lot number (all units)',
              //     txtInputType: TextInputType.text,
              //   ),
              // ],
              if (_usesPieceForm) ...[
                uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace,
                  cusWidth: null,
                ),
                StockInPieceListForm(
                  key: _pieceFormKey,
                  showMeasurements: _isMeasurementBasedClothing,
                  showBatchNumber: _isPharmacy,
                  allowMultiplePieces:
                      widget.batchStockIn || _isMeasurementBasedClothing,
                  businessDetail: _businessDetail,
                  itemModel: widget.itemModel,
                  onPiecesChanged: (pieces) {
                    _pieceEntries = pieces;
                  },
                ),
              ],
              if (_supportsUniqueCodeForm) ...[
                uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace,
                  cusWidth: null,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CusTxtWidget(
                    txt: 'Unique item barcode / serial (Optional)',
                    txtStyle: Theme.of(context).textTheme.titleSmall!,
                  ),
                ),
                uiController.sizedBox(
                  cusHeight: UIConstants.smallSpace,
                  cusWidth: null,
                ),
                CusTxtWidget(
                  txt:
                      'You can scan or type a unique barcode / serial for each physical unit. Leave blank if not needed.',
                  txtStyle: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
                uiController.sizedBox(
                  cusHeight: UIConstants.mediumSpace,
                  cusWidth: null,
                ),
                ...List.generate(_unitCodeControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: UIConstants.mediumSpace,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CusTxtWidget(
                          txt: 'Unit ${index + 1}',
                          txtStyle: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: UIConstants.smallSpace),
                        CusTextFieldLogin(
                          txtController: _unitCodeControllers[index],
                          verticalPadding: UIConstants.mediumSpace,
                          horizontalPadding: UIConstants.bigSpace,
                          hintTxt: 'Scan or enter unique barcode / serial',
                          txtInputType: TextInputType.text,
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.blue,
                            ),
                            onPressed: () => _scanUniqueCodeInto(
                              _unitCodeControllers[index],
                            ),
                          ),
                        ),
                        if (_isPhoneTablets) ...[
                          const SizedBox(height: UIConstants.smallSpace),
                          CusTextFieldLogin(
                            txtController: _imeiControllers[index],
                            verticalPadding: UIConstants.mediumSpace,
                            horizontalPadding: UIConstants.bigSpace,
                            hintTxt: 'IMEI number (Optional)',
                            txtInputType: TextInputType.text,
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
              uiController.sizedBox(
                cusHeight: UIConstants.bigSpace,
                cusWidth: null,
              ),
              if (_canTrackExpiry)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.mediumSpace,
                  ),
                  child: SizedBox(
                    width: 280,
                    child: DatePickerWithTxtField(
                      labelTxt: 'Expired Date',
                      textEditingController: expireDateController,
                      clr: accent,
                      func: (DateTime dateTime) {
                        expireDateController.text = TextFormatters.getDate(
                          dateTime,
                        );
                        expiredDate = dateTime;
                      },
                    ),
                  ),
                ),
              if (_canTrackExpiry &&
                  (_businessType == BusinessType.grocery ||
                      _businessType == BusinessType.convenience) &&
                  _businessDetail?.shelfLifeDays != null)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: UIConstants.smallSpace,
                  ),
                  child: CusTxtWidget(
                    txt:
                        'Default expiry from shelf life (${_businessDetail!.shelfLifeDays} days). You can change it above.',
                    txtStyle: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                  ),
                ),
              if (_canTrackExpiry)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.mediumSpace,
                  ),
                  child: SizedBox(
                    width: 280,
                    child: DatePickerWithTxtField(
                      labelTxt: 'Manufactured Date',
                      textEditingController: manufactureDateController,
                      clr: accent,
                      func: (DateTime dateTime) {
                        manufactureDateController.text = TextFormatters.getDate(
                          dateTime,
                        );
                        manufactureDate = dateTime;
                      },
                    ),
                  ),
                ),
              if (_canTrackExpiry)
                uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace,
                  cusWidth: null,
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: Colors.grey),
                  txt: 'Optional',
                ),
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.smallSpace,
                cusWidth: null,
              ),
              CusTextFieldLogin(
                txtController: placeController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding:
                    UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: 'Get item from where ?',
                txtStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                txtInputType: TextInputType.text,
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<_UniqueItemParents?>(
      future: _parentsFuture,
      builder: (context, snapshot) {
        final parents = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: const CusLeadingBackIconBtn(),
            title: Text('Add Stock in ${widget.itemModel.name}'),
            actions: [
              CusTxtElevatedBtn(
                verticalpadding: 0,
                horizontalpadding: UIConstants.smallSpace,
                bdrRadius: UIConstants.mediumRadius,
                bgClr: Colors.green,

                txtStyle: Theme.of(context).textTheme.titleSmall!,
                txtClr: Theme.of(context).textTheme.titleSmall!.color!,
                txt: 'Create',
                func: () async {
                  try {
                    final validationError = _validateBeforeSubmit();
                    if (validationError != null) {
                      showValidationMessage(validationError);
                      return;
                    }
                    await createNewItemList(parents!);
                  } catch (err, st) {
                    debugPrint(
                      'CreateUniqueStockInScreen: submit failed itemId=${widget.itemModel.id}',
                    );
                    debugPrint(err.toString());
                    debugPrint(st.toString());
                    rethrow;
                  }
                },
              ),

              const SizedBox(width: UIConstants.mediumSpace),
            ],
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : parents == null
              ? NoSelectedIdErrorWidget(
                  txt: 'This item has some missing group data',
                  func: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                )
              : buildForm(parents),
        );
      },
    );
  }
}

class _UniqueItemParents {
  final TypeModel typeModel;
  final GroupModel? groupModel;
  final CategoryModel? categoryModel;

  const _UniqueItemParents({
    required this.typeModel,
    required this.groupModel,
    required this.categoryModel,
  });
}
