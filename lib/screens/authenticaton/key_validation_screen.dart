import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/key_validation_bloc/key_validation_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/screens/authenticaton/check_user_screen.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

class KeyValidationScreen extends StatefulWidget {
  static const String routeName = "/key-validation";

  const KeyValidationScreen({super.key});

  @override
  State<KeyValidationScreen> createState() => _KeyValidationScreenState();
}

class _KeyValidationScreenState extends State<KeyValidationScreen> {
  late TextEditingController _keyController;
  late FocusNode _keyFocusNode;
  final UIController _uiController = UIController.instance;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController();
    _keyFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _keyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType =
        context.select((ThemeCubit cubit) => cubit.state.themeModeType);

    return BlocListener<KeyValidationCubit, KeyValidationState>(
      listener: (context, state) {
        if (state.isKeyValidated) {
          // Navigate to the main app (CheckUserScreen)
          Navigator.of(context).pushNamedAndRemoveUntil(
            CheckUserScreen.routeName,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor:
            _uiController.getpureDirectClr(themeModeType),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.mediumSpace),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: _uiController.getDeviceHeight * 0.1),
                  // Logo
                  const LogoImageWidget(widthandheight: 120),
                  SizedBox(
                    height: _uiController.getDeviceHeight * 0.05,
                  ),
                  // Title
                  Text(
                    'Activate License',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color:
                              _uiController.getpureOppositeClr(themeModeType),
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: _uiController.getDeviceHeight * 0.02,
                  ),
                  // Description
                  Text(
                    'Enter the activation key to get started',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _uiController.getpureOppositeClr(themeModeType)
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: _uiController.getDeviceHeight * 0.06,
                  ),
                  // Key Input Field
                  BlocBuilder<KeyValidationCubit, KeyValidationState>(
                    builder: (context, state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _keyController,
                            focusNode: _keyFocusNode,
                            enabled: !state.isLoading,
                            textCapitalization:
                                TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'Enter activation key',
                              hintStyle: TextStyle(
                                color: _uiController
                                    .getpureOppositeClr(themeModeType)
                                    .withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: _uiController
                                  .getpureOppositeClr(themeModeType)
                                  .withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    UIConstants.mediumRadius),
                                borderSide: BorderSide(
                                  color: state.errorMessage != null
                                      ? Colors.red
                                      : _uiController
                                          .getpureOppositeClr(themeModeType)
                                          .withOpacity(0.2),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    UIConstants.mediumRadius),
                                borderSide: BorderSide(
                                  color: state.errorMessage != null
                                      ? Colors.red
                                      : _uiController
                                          .getpureOppositeClr(themeModeType)
                                          .withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    UIConstants.mediumRadius),
                                borderSide: BorderSide(
                                  color: state.errorMessage != null
                                      ? Colors.red
                                      : _uiController
                                          .getpureOppositeClr(themeModeType),
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    UIConstants.mediumRadius),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: _uiController
                                      .getpureOppositeClr(themeModeType),
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          // Error Message
                          if (state.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: _uiController.getDeviceHeight * 0.04,
                  ),
                  // Validate Button
                  BlocBuilder<KeyValidationCubit, KeyValidationState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: CusTxtElevatedBtn(
                          txt: state.isLoading
                              ? 'Validating...'
                              : 'Activate',
                          verticalpadding: 16,
                          horizontalpadding: 0,
                          bdrRadius: UIConstants.mediumRadius,
                          bgClr: _uiController
                              .getpureOppositeClr(themeModeType),
                          txtClr:
                              _uiController.getpureDirectClr(themeModeType),
                          txtStyle: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          func: state.isLoading
                              ? () {}
                              : () {
                                  _keyFocusNode.unfocus();
                                  context
                                      .read<KeyValidationCubit>()
                                      .validateKey(_keyController.text);
                                },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: _uiController.getDeviceHeight * 0.04,
                  ),
                  // Attempt counter
                  BlocBuilder<KeyValidationCubit, KeyValidationState>(
                    builder: (context, state) {
                      if (state.validationAttempts! > 0) {
                        return Text(
                          'Attempt ${state.validationAttempts} failed',
                          style: TextStyle(
                            color: _uiController
                                .getpureOppositeClr(themeModeType)
                                .withOpacity(0.6),
                            fontSize: 12,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  SizedBox(
                    height: _uiController.getDeviceHeight * 0.08,
                  ),
                  // Information Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _uiController
                          .getpureOppositeClr(themeModeType)
                          .withOpacity(0.05),
                      borderRadius:
                          BorderRadius.circular(UIConstants.mediumRadius),
                      border: Border.all(
                        color: _uiController
                            .getpureOppositeClr(themeModeType)
                            .withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ℹ️ About Activation',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _uiController
                                    .getpureOppositeClr(themeModeType),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This key is exclusive to your device and can only be used once. After activation, you\'ll have full access to the application.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: _uiController
                                    .getpureOppositeClr(themeModeType)
                                    .withOpacity(0.7),
                                height: 1.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
