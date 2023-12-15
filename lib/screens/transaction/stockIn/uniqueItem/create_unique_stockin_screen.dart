import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/cus_datepicker_withtxtfield_widget.dart';

import '../../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../../constants/enums.dart';
import '../../../../controller/ui_controller.dart';
import '../../../../error_handlers/error_handler.dart';
import '../../../../models/groupingItem_models_folders/group_model.dart';
import '../../../../models/groupingItem_models_folders/type_model.dart';
import '../../../../models/user_model_folder/user_model.dart';
import '../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart';
import '../../../../widgets/btns_folder/leadingBackIconBtn.dart';

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


  @override
  void initState() {
    super.initState();
    if(!widget.batchStockIn){
      moreItem = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<UniqueItemModel> uniqueItemList = context.read<ItemCubit>().getSelectedUniqueItemList(widget.itemModel.id);
    final TypeModel typeModel = context.read<ItemCubit>().getType(widget.itemModel.typeId)!;
    final GroupModel groupModel = context.read<ItemCubit>().getGroup(typeModel.groupId);
    final CategoryModel categoryModel = context.read<ItemCubit>().getCategory(groupModel.categoryId);
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;

    Future<void> createNewItemList()async{
      context.read<LoadingCubit>().setLoading("Adding ...");

      await context.read<TransactionsCubit>().createNewUniqueItemList(
        userModel: userModel,
        categoryModel: categoryModel,
        groupModel: groupModel,
        typeModel: typeModel,
        itemModel: widget.itemModel,
        code: null,
        itemManufactureDate: widget.itemModel.hasExpire ? manufactureDate : null,
        itemExpireDate: widget.itemModel.hasExpire ? expiredDate : null,
        getItemFromWhere: placeController.text.trim().isEmpty || placeController.text.trim() == ""
            ?
        null
            :
        placeController.text.trim()
        ,
        itemLength: moreItem,
      ).then((value){

        if(value){
          context.read<ItemCubit>().reloadAllItem().then((_){
            Navigator.of(context).pop();

            context.read<LoadingCubit>().setSuccess("Success !");
          });

        }else{
          context.read<LoadingCubit>().setFail("Fail !");
        }
      });

    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CusLeadingBackIconBtn(),
        title: Text(
          "Add Stock in ${widget.itemModel.name}",
        ),
      ),
      body: SingleChildScrollView(
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
                      txtStyle:  Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: uiController.getpureDirectClr(themeModeType),
                      ),
                    ),
                  ),
                  CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleMedium!,
                    txt:  "  +  $moreItem",
                  ),
                ],
              ),
              if(widget.batchStockIn)Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CusIconBtn(
                    size: UIConstants.normalBigIconSize,
                    func: (){
                      setState(() {
                        if(moreItem < 999){
                          setState(() {
                            moreItem ++;
                          });
                        }
                      });
                    },
                    clr: Colors.green,
                    icon: Icons.plus_one,
                  ),
                  uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.bigSpace),
                  CusIconBtn(
                    size: UIConstants.normalBigIconSize,
                    func: (){
                      setState(() {
                        if(moreItem > 0){
                          setState(() {
                            moreItem --;
                          });
                        }
                      });
                    },
                    clr: Colors.red,
                    icon: Icons.exposure_minus_1,
                  ),
                ],
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              if(widget.itemModel.hasExpire)Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.mediumSpace,
                ),
                child: SizedBox(
                  width: 280,
                  child: DatePickerWithTxtField(
                    labelTxt: "Expired Date",
                    textEditingController: expireDateController,
                    clr: Colors.indigoAccent,
                    func: (DateTime dateTime){
                      expireDateController.text = TextFormatters.getDate(dateTime);
                      expiredDate = dateTime;
                    },
                  ),
                ),
              ),
              if(widget.itemModel.hasExpire)Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.mediumSpace,
                ),
                child: SizedBox(
                  width: 280,
                  child: DatePickerWithTxtField(
                    labelTxt: "Manufactured Date",
                    textEditingController: manufactureDateController,
                    clr: Colors.indigoAccent,
                    func: (DateTime dateTime){
                      manufactureDateController.text = TextFormatters.getDate(dateTime);
                      manufactureDate = dateTime;
                    },
                  ),
                ),
              ),
              if(widget.itemModel.hasExpire)uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.grey
                  ),
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
                  func: ()async{
                    if(widget.itemModel.hasExpire){
                      if(expiredDate == null){
                        errorHandlers.showErrorWithBtn(title: "Add Expired Date", txt: "This item can be expired.");
                      }else{
                        if(widget.batchStockIn){
                          if(moreItem < 1){
                            errorHandlers.showErrorWithBtn(title: null, txt: "Please add stock");
                          }else{
                            await createNewItemList();
                          }
                        }else{
                          await createNewItemList();
                        }
                      }
                    }else{
                      if(widget.batchStockIn){
                        if(moreItem < 1){
                          errorHandlers.showErrorWithBtn(title: null, txt: "Please add stock");
                        }else{
                          await createNewItemList();
                        }
                      }else{
                        await createNewItemList();
                      }
                    }
                  },
                  clr: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
