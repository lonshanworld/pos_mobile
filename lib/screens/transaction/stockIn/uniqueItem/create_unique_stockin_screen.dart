import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
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
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTextOnlyBtn_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/cus_datepicker_withtxtfield_widget.dart';

class CreateUniqueStockInScreen extends StatefulWidget {
  final ItemModel itemModel;
  final bool batchStockIn;

  const CreateUniqueStockInScreen({
    super.key,
    required this.itemModel,
    required this.batchStockIn,
  });

  @override
  State<CreateUniqueStockInScreen> createState() => _CreateUniqueStockInScreenState();
}

class _CreateUniqueStockInScreenState extends State<CreateUniqueStockInScreen> {
  final TextEditingController expireDateController = TextEditingController();
  final TextEditingController manufactureDateController = TextEditingController();
  final TextEditingController placeController = TextEditingController();

  int moreItem = 0;
  DateTime? expiredDate;
  DateTime? manufactureDate;
  late final Future<_UniqueItemParents?> _parentsFuture;

  @override
  void initState() {
    super.initState();
    if (!widget.batchStockIn) {
      moreItem = 1;
    }
    _parentsFuture = _loadParents();
  }

  Future<_UniqueItemParents?> _loadParents() async {
    try {
      final TypeModel? typeModel = await DBHelper.getTypeById(widget.itemModel.typeId);
      if (typeModel == null) {
        debugPrint(
          'CreateUniqueStockInScreen: missing type for itemId=${widget.itemModel.id}, typeId=${widget.itemModel.typeId}',
        );
        return null;
      }

      final GroupModel? groupModel = await DBHelper.getGroupById(typeModel.groupId);
      if (groupModel == null) {
        debugPrint(
          'CreateUniqueStockInScreen: missing group for itemId=${widget.itemModel.id}, groupId=${typeModel.groupId}',
        );
        return null;
      }

      final CategoryModel? categoryModel = await DBHelper.getCategoryById(groupModel.categoryId);
      if (categoryModel == null) {
        debugPrint(
          'CreateUniqueStockInScreen: missing category for itemId=${widget.itemModel.id}, categoryId=${groupModel.categoryId}',
        );
        return null;
      }

      return _UniqueItemParents(
        typeModel: typeModel,
        groupModel: groupModel,
        categoryModel: categoryModel,
      );
    } catch (err, st) {
      debugPrint('CreateUniqueStockInScreen: failed to load parent records for itemId=${widget.itemModel.id}');
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<UniqueItemModel> uniqueItemList = context.read<ItemCubit>().getSelectedUniqueItemList(widget.itemModel.id);
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;

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

      try {
        loadingCubit.setLoading("Adding ...");

        final value = await transactionsCubit.createNewUniqueItemList(
          userModel: userModel,
          categoryModel: parents.categoryModel,
          groupModel: parents.groupModel,
          typeModel: parents.typeModel,
          itemModel: widget.itemModel,
          code: null,
          itemManufactureDate: widget.itemModel.hasExpire ? manufactureDate : null,
          itemExpireDate: widget.itemModel.hasExpire ? expiredDate : null,
          getItemFromWhere: placeController.text.trim().isEmpty ? null : placeController.text.trim(),
          itemLength: moreItem,
        );

        if (!mounted) return;
        if (value) {
          await itemCubit.reloadAllItem();
          if (!mounted) return;
          navigator.pop();
          loadingCubit.setSuccess("Success !");
        } else {
          loadingCubit.setFail("Fail !");
        }
      } catch (err, st) {
        debugPrint('CreateUniqueStockInScreen: create stock-in failed for itemId=${widget.itemModel.id}');
        debugPrint(err.toString());
        debugPrint(st.toString());
        rethrow;
      }
    }

    Widget buildForm(_UniqueItemParents parents) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.bigSpace,
            vertical: UIConstants.mediumSpace,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleSmall!,
                    txt: "Stock :  ",
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
                      txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: uiController.getpureDirectClr(themeModeType),
                          ),
                    ),
                  ),
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleMedium!,
                    txt: "  +  $moreItem",
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
                          }
                        });
                      },
                      clr: Colors.green,
                      icon: Icons.plus_one,
                    ),
                    uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.bigSpace),
                    CusIconBtn(
                      size: UIConstants.normalBigIconSize,
                      hasBorder: true,
                      func: () {
                        setState(() {
                          if (moreItem > 0) {
                            moreItem--;
                          }
                        });
                      },
                      clr: Colors.red,
                      icon: Icons.exposure_minus_1,
                    ),
                  ],
                ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              if (widget.itemModel.hasExpire)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.mediumSpace,
                  ),
                  child: SizedBox(
                    width: 280,
                    child: DatePickerWithTxtField(
                      labelTxt: "Expired Date",
                      textEditingController: expireDateController,
                      clr: Colors.indigoAccent,
                      func: (DateTime dateTime) {
                        expireDateController.text = TextFormatters.getDate(dateTime);
                        expiredDate = dateTime;
                      },
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
                      labelTxt: "Manufactured Date",
                      textEditingController: manufactureDateController,
                      clr: Colors.indigoAccent,
                      func: (DateTime dateTime) {
                        manufactureDateController.text = TextFormatters.getDate(dateTime);
                        manufactureDate = dateTime;
                      },
                    ),
                  ),
                ),
              if (widget.itemModel.hasExpire)
                uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(color: Colors.grey),
                  txt: "Optional",
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.smallSpace, cusWidth: null),
              CusTextFieldLogin(
                txtController: placeController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Get item from where ?",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                    ),
                txtInputType: TextInputType.text,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Create",
                  clr: Colors.deepPurpleAccent,
                  func: () async {
                    try {
                      if (widget.itemModel.hasExpire) {
                        if (expiredDate == null) {
                          showValidationMessage("Please add expired date");
                          return;
                        }
                      }

                      if (widget.batchStockIn && moreItem < 1) {
                        showValidationMessage("Please add stock");
                        return;
                      }

                      await createNewItemList(parents);
                    } catch (err, st) {
                      debugPrint('CreateUniqueStockInScreen: create button failed for itemId=${widget.itemModel.id}');
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
            title: Text("Add Stock in ${widget.itemModel.name}"),
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : parents == null
                  ? NoSelectedIdErrorWidget(
                      txt: "This item has some missing group data",
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
