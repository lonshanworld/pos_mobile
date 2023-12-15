import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../../error_handlers/error_handler.dart';
import '../../utils/ui_responsive_calculation.dart';
import '../../widgets/btns_folder/cusIconBtn_widget.dart';

class CreatePromotionScreen extends StatefulWidget {

  final VoidCallback goBackToListScreen;
  const CreatePromotionScreen({
    super.key,
    required this.goBackToListScreen,
  });

  @override
  State<CreatePromotionScreen> createState() => _CreatePromotionScreenState();
}

class _CreatePromotionScreenState extends State<CreatePromotionScreen> {
  final TextEditingController promotionNameController = TextEditingController();
  final TextEditingController promotionDescriptionController = TextEditingController();
  final TextEditingController promotionPriceController = TextEditingController();
  int? promotionPercentage;
  double? promotionPrice;
  SetPromotion setPromotion = SetPromotion.percentage;


  @override
  void initState() {
    super.initState();
    promotionPriceController.addListener(() {
      if(mounted){
        setState(() {
          promotionPrice = promotionPriceController.text.trim() == "" ? null : double.tryParse(promotionPriceController.text.trim()) == 0 ? null : double.tryParse(promotionPriceController.text.trim());
        });
      }
    });
  }

  @override
  void dispose() {
    promotionNameController.dispose();
    promotionDescriptionController.dispose();
    promotionPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UIController uiController = UIController.instance;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final UIutils uIutils = UIutils();
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;

    void clearAllPromotionData(){
      promotionPercentage = null;
      promotionPrice = null;
      promotionPriceController.clear();
    }


    Widget promotionTextField(TextEditingController controller, String labetTxt, TextInputType inputType ){
      return CusTextFieldLogin(
        txtController: controller,
        verticalPadding: UIConstants.mediumSpace,
        horizontalPadding: UIConstants.bigSpace,
        hintTxt: labetTxt,
        txtInputType: inputType,
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Create new promotion",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        leading: CusIconBtn(
          size: UIConstants.bigIcon,
          func: (){
            widget.goBackToListScreen();
          },
          clr: uiController.getpureOppositeClr(themeModeType),
          icon: Icons.arrow_back,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: uIutils.createUserAccountScreenWidthTextField(),
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.bigSpace,
            ),
            child: Column(
              children: [
                uiController.sizedBox(
                    cusHeight: uiController.getDeviceHeight / 10, cusWidth: null),
                promotionTextField(
                  promotionNameController,
                  "Enter promotion title",
                  TextInputType.text
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace * 2, cusWidth: null),
                promotionTextField(
                  promotionDescriptionController,
                  "Enter description",
                  TextInputType.text,
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace * 2, cusWidth: null),
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Choose promotion type to apply",
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    DropdownButton(
                      dropdownColor: uiController.getpureDirectClr(themeModeType),
                      borderRadius: UIConstants.mediumBorderRadius,
                      value: setPromotion,
                      items: SetPromotion.values.map((e) => DropdownMenuItem<SetPromotion>(
                        value: e,
                        child: CusTxtWidget(
                          txtStyle: Theme.of(context).textTheme.titleSmall!,
                          txt: e == SetPromotion.percentage ? "With percentage (%)" : "With price (MMK)",
                        ),
                      )).toList(),
                      onChanged: (data){
                        if(data != null){
                          clearAllPromotionData();
                          if(mounted){
                            setState(() {
                              setPromotion = data;
                            });
                          }
                        }
                      },
                    ),
                    uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.mediumSpace),
                    Icon(
                      Icons.touch_app,
                      size: UIConstants.normalNormalIconSize,
                      color: uiController.getpureOppositeClr(themeModeType),
                    ),

                  ],
                ),
                if(setPromotion == SetPromotion.mmk)uiController.sizedBox(cusHeight: UIConstants.bigSpace , cusWidth: null),
                if(setPromotion == SetPromotion.mmk)promotionTextField(
                  promotionPriceController,
                  "Enter promotion amount (MMK)",
                  TextInputType.number,
                ),
                if(setPromotion == SetPromotion.percentage)Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CusTxtWidget(
                      txtStyle: Theme.of(context).textTheme.titleSmall!,
                      txt: "Choose percentage",
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius:UIConstants.bigBorderRadius,
                          border: Border.all(
                            color: Colors.pinkAccent,
                            width: 1,
                          )
                      ),
                      child: NumberPicker(
                        minValue: 0,
                        maxValue: 100,
                        textMapper: (data){
                          cusDebugPrint(data);
                          return "$data %";
                        },
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        selectedTextStyle: Theme.of(context).textTheme.titleMedium!,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                        value: promotionPercentage ?? 0,
                        onChanged: (data){
                          if(mounted){

                            setState(() {
                              if(data == 0){
                                promotionPercentage == null;
                              }else{
                                promotionPercentage = data;
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
                CusTxtElevatedBtn(
                  txt: "Create",
                  verticalpadding: UIConstants.mediumSpace,
                  horizontalpadding: UIConstants.bigSpace,
                  bdrRadius: UIConstants.mediumRadius,
                  bgClr: Colors.pinkAccent,
                  func: ()async{
                    if(promotionNameController.text.trim().isEmpty){
                      errorHandlers.showErrorWithBtn(
                        title: null,
                        txt: "Promotion title should not be empty",
                      );
                    }else if(promotionPrice == null && promotionPercentage == null){
                      errorHandlers.showErrorWithBtn(
                        title: "Empty promotion",
                        txt: setPromotion == SetPromotion.mmk ? "Promotion Price should not be empty" : "Promotion Percentage should not be empty",
                      );
                    }else{

                      context.read<LoadingCubit>().setLoading("Creating ...");
                      await context.read<PromotionCubit>().addNewPromotion(
                        promotionName: promotionNameController.text.trim(),
                        promotionDescription: promotionDescriptionController.text.trim(),
                        promotionPercentage: promotionPercentage == 0 ? null : promotionPercentage?.toDouble(),
                        promotionPrice: promotionPrice == 0 ? null : promotionPrice,
                        userModel: userModel!,
                      ).then((value){
                        if(value){
                          context.read<LoadingCubit>().setSuccess("Success !");
                          widget.goBackToListScreen();
                        }else{
                          context.read<LoadingCubit>().setFail("Fail !");
                        }
                      });
                    }

                  },
                  txtStyle: Theme.of(context).textTheme.titleSmall!,
                  txtClr: Colors.white,
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace * 2, cusWidth: null),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
