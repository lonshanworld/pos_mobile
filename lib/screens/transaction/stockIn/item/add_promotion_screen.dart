import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/error_handlers/error_handler.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/promotion/promotion_widget.dart';


import '../../../../models/user_model_folder/user_model.dart';

class AddPromotionToItemScreen extends StatefulWidget {

  final ItemModel itemModel;
  const AddPromotionToItemScreen({
    super.key,
    required this.itemModel,
  });

  @override
  State<AddPromotionToItemScreen> createState() => _AddPromotionToItemScreenState();
}

class _AddPromotionToItemScreenState extends State<AddPromotionToItemScreen> {
  int? selectedIndex;
  PromotionModel? selectedPromotion;

  @override
  Widget build(BuildContext context) {
    final List<PromotionModel> promotionList = context.watch<PromotionCubit>().state.activePromotionList;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final ErrorHandlers errorHandlers = ErrorHandlers();

    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        centerTitle: true,
        title: Text("Add Promotion to ${widget.itemModel.name}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: UIConstants.mediumSpace,
            ),
            child: CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Colors.grey,
              ),
              txt: "Choose one promotion",
            ),
          ),
          Expanded(
            child: ListView(
              children: promotionList.reversed.map((e){
                return InkWell(
                  onTap: (){
                    if(mounted){
                      setState(() {
                        selectedIndex = promotionList.indexOf(e);
                        selectedPromotion = e;
                      });
                    }
                  },
                  child: Container(
                    width: double.maxFinite,
                    height: 150,
                    color: selectedIndex == promotionList.indexOf(e) ? Colors.green.withOpacity(0.4) : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.bigSpace,
                      vertical: UIConstants.mediumSpace,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: PromotionWidget(
                                promotionModel: e,
                                index: promotionList.indexOf(e) + 1),
                          ),
                        ),
                        if(selectedIndex == promotionList.indexOf(e))const Positioned(
                          top: 10,
                          right: 10,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: UIConstants.normalNormalIconSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            width: 100,
            height: 80,
            padding:const EdgeInsets.symmetric(
              vertical: UIConstants.bigSpace
            ),
            child: CusTxtIconElevatedBtn(
              txt: "Add",
              verticalpadding: UIConstants.smallSpace,
              horizontalpadding: UIConstants.mediumSpace,
              bdrRadius: UIConstants.smallRadius,
              bgClr: Colors.greenAccent,
              txtStyle: Theme.of(context).textTheme.titleSmall!,
              txtClr: Colors.black,
              func: ()async{
                if(selectedPromotion == null){
                  errorHandlers.showErrorWithBtn(title: "Promotion not found !", txt: "Promotion item is not selected. Please select one item and click add button");
                }else{
                  context.read<LoadingCubit>().setLoading("Adding ...");
                  await context.read<PromotionCubit>().attachItemWithPromotion(
                    userModel: userModel!,
                    promotionId: selectedPromotion!.id,
                    itemId: widget.itemModel.id,
                  ).then((value){
                    if(value){
                      Navigator.of(context).pop();
                      context.read<LoadingCubit>().setSuccess("Success !");
                    }else{
                      context.read<LoadingCubit>().setFail("Failed !");
                    }
                  });

                }
              },
              icon: Icons.add,
              iconSize: UIConstants.normalNormalIconSize,
            ),
          ),
        ],
      ),

    );
  }
}
