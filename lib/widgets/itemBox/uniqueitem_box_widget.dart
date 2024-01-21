import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';
import 'package:pos_mobile/widgets/index_box_widget.dart';

/**
 * TODO : show
 * index No.
 *  itemId
 *  createTime
 *  itemExpireDate
 *  itemManufactureDate
 *  code
 *  createPersonId
 *  lastupdateTime
 *  original Price
 *  profit price
 *  taxpercentage
 */

class UniqueItemBoxWidget extends StatelessWidget {

  final UniqueItemModel uniqueItemModel;
  final int index;
  const UniqueItemBoxWidget({
    super.key,
    required this.uniqueItemModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;

    Widget doubleRowStrings(String txt1, String txt2){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.grey,
            ),
            txt: txt1,
          ),
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.normal,
            ),
            txt: txt2,
          ),
        ],
      );
    }

    List<Widget> keyValueList(){
      // return uniqueItemModel.toJson().entries.map((e) => doubleRowStrings(
      //     e.key,
      //     e.value.toString(),
      // )).toList();
      UserModel? createdPersonModel = context.read<UserDataCubit>().getSingleUser(uniqueItemModel.createPersonId);
      return [
        doubleRowStrings("Id", uniqueItemModel.id.toString()),
        doubleRowStrings("Created person name", createdPersonModel!.userName),
        doubleRowStrings("Create time", TextFormatters.getDateTime(uniqueItemModel.createTime)),
        doubleRowStrings("Last update time", uniqueItemModel.lastUpdateTime == null ? "--" : TextFormatters.getDateTime(uniqueItemModel.lastUpdateTime)),
        doubleRowStrings("Original Price", uniqueItemModel.originalPrice.toString()),
        doubleRowStrings("Profit Price", uniqueItemModel.profitPrice.toString()),
        doubleRowStrings("Active status", uniqueItemModel.activeStatus.toString())
      ];
    }

    return SizedBox(
      width: UIConstants.uniqueItemBoxWidth + 10,
      child: Slidable(
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (ctx){
                context.read<LoadingCubit>().setLoading("Deleting ...");
                context.read<ItemCubit>().deleteUniqueItem(uniqueItemModel, userModel!).then((value){
                  if(value){
                    context.read<LoadingCubit>().setSuccess("Success !");
                  }else{
                    context.read<LoadingCubit>().setFail("Fail !");
                  }
                });
              },
              backgroundColor: UIConstants.deepBlueClr,
              label: "Delete",
              spacing: 0,
              flex: 1,
              borderRadius: const BorderRadius.all(Radius.circular(UIConstants.bigRadius)),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: uiController.getpureDirectClr(themeModeType),
            borderRadius: const BorderRadius.all(Radius.circular(UIConstants.mediumSpace)),
            boxShadow: [
              uiController.boxShadow(themeModeType),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IndexBoxWidget(index: (index + 1).toString()),
              Padding(
                padding: const EdgeInsets.only(
                  left: UIConstants.mediumSpace,
                  right: UIConstants.mediumSpace,
                  bottom: UIConstants.mediumSpace,
                ),
                child: Column(
                  children: keyValueList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
