import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:pos_mobile/blocs/confirm_by_password_bloc/confirm_by_password_cubit.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';


class ConfirmByPasswordScreen extends StatelessWidget {

  final String title;
  final String txt;
  final VoidCallback successFunc;

  const ConfirmByPasswordScreen({
    super.key,
    required this.title,
    required this.txt,
    required this.successFunc,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        centerTitle: true,
        title: Text(
          title
        ),
      ),
      body: Column(
        children: [
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!,
            txt: txt,
          ),
          BlocBuilder<ConfirmByPasswordCubit, ConfirmByPasswordState>(
            builder: (ctx, state){
              return Pinput(
                length: state.userModel!.password.length,
                controller: ctx.read<ConfirmByPasswordCubit>().pinController,
                onCompleted: (String data){
                  ctx.read<ConfirmByPasswordCubit>().confirmFunc();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
