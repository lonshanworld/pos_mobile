import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:pos_mobile/blocs/confirm_by_password_bloc/confirm_by_password_cubit.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

class ConfirmByPasswordScreen extends StatefulWidget {
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
  State<ConfirmByPasswordScreen> createState() =>
      _ConfirmByPasswordScreenState();
}

class _ConfirmByPasswordScreenState extends State<ConfirmByPasswordScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!,
            txt: widget.txt,
          ),
          BlocBuilder<ConfirmByPasswordCubit, ConfirmByPasswordState>(
            builder: (ctx, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Pinput(
                    length: state.userModel!.password.length,
                    controller: ctx
                        .read<ConfirmByPasswordCubit>()
                        .pinController,
                    obscureText: _obscurePassword,
                    onCompleted: (String data) {
                      ctx.read<ConfirmByPasswordCubit>().confirmFunc();
                    },
                  ),
                  IconButton(
                    tooltip: _obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
