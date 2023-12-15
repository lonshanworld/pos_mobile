import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/constants/uiConstants.dart";

import "../blocs/theme_bloc/theme_cubit.dart";
import "../constants/enums.dart";

class DatePickerWithTxtField extends StatefulWidget {

  final String labelTxt;
  final TextEditingController textEditingController;
  final Color clr;
  final Function(DateTime dateTime) func;

  const DatePickerWithTxtField({
    super.key,
    required this.labelTxt,
    required this.textEditingController,
    required this.clr,
    required this.func,
  });

  @override
  State<DatePickerWithTxtField> createState() => _DatePickerWithTxtFieldState();
}

class _DatePickerWithTxtFieldState extends State<DatePickerWithTxtField> {
  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: widget.clr,
        width: 1,
      ),
      borderRadius: UIConstants.mediumBorderRadius,
    );


    Future<void> showPicker()async{
      DateTime? pickDate = await showDatePicker(
        context: context,
        builder: (context, child){
          return Theme(
            data: ThemeData(
              brightness: themeModeType == ThemeModeType.dark ? Brightness.dark : Brightness.light,
              datePickerTheme: Theme.of(context).datePickerTheme,
              dropdownMenuTheme: DropdownMenuThemeData(
                textStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.indigoAccent,
                )
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.indigoAccent,
                ),
              )
            ),
            child: child!,
          );
        },
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if(pickDate != null){
        widget.func(pickDate);
      }
    }

    return TextField(
      controller: widget.textEditingController,
      readOnly: true,
      onTap: (){
        showPicker();
      },
      keyboardType: TextInputType.datetime,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: widget.clr,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
          labelText: widget.labelTxt,
          labelStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: widget.clr,
          ),
          filled: false,
          prefixIcon: Icon(
            Icons.calendar_month,
            size: UIConstants.bigIcon,
            color: widget.clr,
          ),
          border: outlineInputBorder,
          focusedBorder: outlineInputBorder,
          enabledBorder: outlineInputBorder,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.bigSpace,
            vertical: UIConstants.mediumSpace,
          )
      ),
    );
  }
}
