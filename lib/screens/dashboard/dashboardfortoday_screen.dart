import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/screens/dashboard/dashboard_stockOut_widget.dart';
import 'package:pos_mobile/screens/dashboard/dashboard_stockin_widget.dart';

import '../../blocs/userData_bloc/user_data_cubit.dart';
import '../../constants/uiConstants.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../widgets/loading_widget.dart';

class DashBoardForTodayScreen extends StatelessWidget {
  static const String routeName = "/dashboard";
  static const double desktopBreakpoint = 1024;
  static const double tabletBreakpoint = 600;

  const DashBoardForTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final Orientation orientation = mediaQuery.orientation;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: userModel == null
            ? const Center(child: LoadingWidget())
            : LayoutBuilder(
                builder: (BuildContext ctx, BoxConstraints constraints) {
                  // Determine layout based on screen width and orientation
                  final bool isDesktop = screenWidth >= desktopBreakpoint;
                  final bool isTablet = screenWidth >= tabletBreakpoint && screenWidth < desktopBreakpoint;
                  final bool isLandscape = orientation == Orientation.landscape;

                  // Calculate responsive padding
                  final double horizontalPadding = isDesktop 
                      ? UIConstants.bigSpace * 2
                      : isTablet 
                          ? UIConstants.bigSpace 
                          : UIConstants.mediumSpace;
                  
                  final double verticalPadding = isLandscape 
                      ? UIConstants.smallSpace 
                      : UIConstants.mediumSpace;

                  // Calculate max width for side-by-side layout
                  final double availableWidth = constraints.maxWidth - (horizontalPadding * 2);
                  final bool showSideBySide = isDesktop || (isTablet && !isLandscape);

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: showSideBySide
                        ? _buildSideBySideLayout(availableWidth)
                        : _buildVerticalLayout(),
                  );
                },
              ),
      ),
    );
  }

  /// Side-by-side layout for larger screens
  Widget _buildSideBySideLayout(double availableWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stock In Section
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 400),
            child: const DashboardStockIn(),
          ),
        ),
        // Vertical Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: UIConstants.mediumSpace),
          width: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.withValues(alpha: 0.1),
                Colors.grey.withValues(alpha: 0.3),
                Colors.grey.withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        // Stock Out Section
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 400),
            child: const DashboardStockOut(),
          ),
        ),
      ],
    );
  }

  /// Vertical layout for smaller screens
  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stock In Section
          Container(
            constraints: const BoxConstraints(minHeight: 300),
            child: const DashboardStockIn(),
          ),
          // Spacing
          const SizedBox(height: UIConstants.bigSpace),
          // Horizontal Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.grey.withValues(alpha: 0.1),
                  Colors.grey.withValues(alpha: 0.3),
                  Colors.grey.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          // Spacing
          const SizedBox(height: UIConstants.bigSpace),
          // Stock Out Section
          Container(
            constraints: const BoxConstraints(minHeight: 300),
            child: const DashboardStockOut(),
          ),
        ],
      ),
    );
  }
}
