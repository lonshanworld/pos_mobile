import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
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
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTextOnlyBtn_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/cus_datepicker_withtxtfield_widget.dart';
import 'package:pos_mobile/widgets/stock_in_unit_fields.dart';

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

  int moreItem = 0;
  DateTime? expiredDate;
  DateTime? manufactureDate;
  late final Future<_UniqueItemParents?> _parentsFuture;
  ItemBusinessDetailModel? _businessDetail;
  BusinessType? _businessType;

  bool get _isClothing => _businessType == BusinessType.clothing;

  bool get _isPharmacy => _businessType == BusinessType.basicPharmacy;

  /// Clothing always uses per-piece sizes; pharmacy uses per-piece batch on single stock-in.
  bool get _usesPieceForm =>
      _isClothing || (_isPharmacy && !widget.batchStockIn);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _businessType ??= context.read<ShopInfoCubit>().state.businessType;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.batchStockIn) {
      moreItem = 1;
    }
    _parentsFuture = _loadParents();
    _loadBusinessDetail();
  }

  Future<void> _loadBusinessDetail() async {
    final detail =
        await DBHelper.getItemBusinessDetail(widget.itemModel.id);
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
    if (!widget.itemModel.hasExpire) {
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
      final TypeModel? typeModel =
          await DBHelper.getTypeById(widget.itemModel.typeId);
      if (typeModel == null) return null;

      final GroupModel? groupModel =
          await DBHelper.getGroupById(typeModel.groupId);
      if (groupModel == null) return null;

      final CategoryModel? categoryModel =
          await DBHelper.getCategoryById(groupModel.categoryId);
      if (categoryModel == null) return null;

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
    super.dispose();
  }

  List<StockInUnitSpec>? _buildUnitSpecs() {
    if (_isClothing) {
      final pieces = _pieceFormKey.currentState?.pieces ?? [];
      if (pieces.isEmpty) return null;
      return StockInUnitBuilder.fromClothingPieces(
        pieces: pieces,
        itemModel: widget.itemModel,
        businessDetail: _businessDetail,
      );
    }

    if (_isPharmacy) {
      if (widget.batchStockIn) {
        final batch = pharmacyBatchController.text.trim();
        if (batch.isEmpty) return null;
        return StockInUnitBuilder.fromPharmacyBatch(
          batchNumber: batch,
          count: moreItem,
          itemModel: widget.itemModel,
        );
      }
      final pieces = _pieceFormKey.currentState?.pieces ?? [];
      if (pieces.isEmpty) return null;
      return StockInUnitBuilder.fromPharmacyPieces(
        pieces: pieces,
        itemModel: widget.itemModel,
      );
    }

    return null;
  }

  String? _validateBeforeSubmit() {
    if (widget.itemModel.hasExpire && expiredDate == null) {
      return 'Please add expired date';
    }

    if (_isClothing) {
      final pieces = _pieceFormKey.currentState?.pieces ?? [];
      if (pieces.isEmpty) return 'Add at least one piece';
      for (int i = 0; i < pieces.length; i++) {
        final length =
            double.tryParse(pieces[i].lengthController.text.trim());
        final width = double.tryParse(pieces[i].widthController.text.trim());
        if (length == null || length <= 0 || width == null || width <= 0) {
          return 'Enter valid length and width for piece ${i + 1}';
        }
      }
      final rate = _businessDetail?.pricePerMeasurementUnit;
      if (rate == null || rate <= 0) {
        return 'Set price per measurement unit on the item first (edit item)';
      }
      return null;
    }

    if (_isPharmacy) {
      if (widget.batchStockIn) {
        if (pharmacyBatchController.text.trim().isEmpty) {
          return 'Enter batch / lot number';
        }
        if (moreItem < 1) return 'Please add stock quantity';
        return null;
      }
      final pieces = _pieceFormKey.currentState?.pieces ?? [];
      if (pieces.isEmpty) return 'Add at least one unit';
      for (int i = 0; i < pieces.length; i++) {
        if (pieces[i].batchController.text.trim().isEmpty) {
          return 'Enter batch number for unit ${i + 1}';
        }
      }
      return null;
    }

    if (widget.batchStockIn && moreItem < 1) {
      return 'Please add stock';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final List<UniqueItemModel> uniqueItemList =
        context.read<ItemCubit>().getSelectedUniqueItemList(widget.itemModel.id);
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType =
        context.watch<ThemeCubit>().state.themeModeType;
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;
    final accent = uiController.accentColor();

    void showValidationMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
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

      if (_isClothing && (unitSpecs == null || unitSpecs.isEmpty)) {
        showValidationMessage('Invalid clothing piece measurements.');
        return;
      }

      final int itemLength = unitSpecs?.length ??
          (widget.batchStockIn ? moreItem : 1);

      try {
        loadingCubit.setLoading('Adding ...');

        final value = await transactionsCubit.createNewUniqueItemList(
          userModel: userModel,
          categoryModel: parents.categoryModel,
          groupModel: parents.groupModel,
          typeModel: parents.typeModel,
          itemModel: widget.itemModel,
          code: null,
          itemManufactureDate:
              widget.itemModel.hasExpire ? manufactureDate : null,
          itemExpireDate: widget.itemModel.hasExpire ? expiredDate : null,
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
          navigator.pop();
          loadingCubit.setSuccess('Success !');
        } else {
          loadingCubit.setFail('Fail !');
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

    Widget buildForm(_UniqueItemParents parents) {
      final pieceCount = _pieceFormKey.currentState?.pieces.length ?? 1;
      final addingCount = _usesPieceForm ? pieceCount : moreItem;

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
                      txtStyle:
                          Theme.of(context).textTheme.titleMedium!.copyWith(
                                color:
                                    uiController.getpureDirectClr(themeModeType),
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
              if (widget.batchStockIn && !_usesPieceForm)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CusIconBtn(
                      size: UIConstants.normalBigIconSize,
                      hasBorder: true,
                      func: () {
                        setState(() {
                          if (moreItem < 999) moreItem++;
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
                          if (moreItem > 0) moreItem--;
                        });
                      },
                      clr: Colors.red,
                      icon: Icons.exposure_minus_1,
                    ),
                  ],
                ),
              if (_isPharmacy && widget.batchStockIn) ...[
                uiController.sizedBox(
                  cusHeight: UIConstants.mediumSpace,
                  cusWidth: null,
                ),
                CusTextFieldLogin(
                  txtController: pharmacyBatchController,
                  verticalPadding: UIConstants.mediumSpace,
                  horizontalPadding: UIConstants.bigSpace,
                  hintTxt: 'Batch / lot number (all units)',
                  txtInputType: TextInputType.text,
                ),
              ],
              if (_usesPieceForm) ...[
                uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace,
                  cusWidth: null,
                ),
                StockInPieceListForm(
                  key: _pieceFormKey,
                  showMeasurements: _isClothing,
                  showBatchNumber: _isPharmacy,
                  allowMultiplePieces: widget.batchStockIn || _isClothing,
                  businessDetail: _businessDetail,
                  itemModel: widget.itemModel,
                ),
              ],
              uiController.sizedBox(
                cusHeight: UIConstants.bigSpace,
                cusWidth: null,
              ),
              if (widget.itemModel.hasExpire)
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
                        expireDateController.text =
                            TextFormatters.getDate(dateTime);
                        expiredDate = dateTime;
                      },
                    ),
                  ),
                ),
              if (widget.itemModel.hasExpire &&
                  (_businessType == BusinessType.grocery ||
                      _businessType == BusinessType.convenience) &&
                  _businessDetail?.shelfLifeDays != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: UIConstants.smallSpace),
                  child: CusTxtWidget(
                    txt:
                        'Default expiry from shelf life (${_businessDetail!.shelfLifeDays} days). You can change it above.',
                    txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              if (widget.itemModel.hasExpire)
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
                        manufactureDateController.text =
                            TextFormatters.getDate(dateTime);
                        manufactureDate = dateTime;
                      },
                    ),
                  ),
                ),
              if (widget.itemModel.hasExpire)
                uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace,
                  cusWidth: null,
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Colors.grey),
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
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: 'Get item from where ?',
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                    ),
                txtInputType: TextInputType.text,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: 'Create',
                  clr: accent,
                  func: () async {
                    try {
                      final validationError = _validateBeforeSubmit();
                      if (validationError != null) {
                        showValidationMessage(validationError);
                        return;
                      }
                      await createNewItemList(parents);
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
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : parents == null
                  ? NoSelectedIdErrorWidget(
                      txt: 'This item has some missing group data',
                      func: () => Navigator.of(context).pop(),
                    )
                  : buildForm(parents),
        );
      },
    );
  }
}

class _UniqueItemParents {
  final TypeModel typeModel;
  final GroupModel groupModel;
  final CategoryModel categoryModel;

  const _UniqueItemParents({
    required this.typeModel,
    required this.groupModel,
    required this.categoryModel,
  });
}
