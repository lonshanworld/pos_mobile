import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import 'package:pos_mobile/widgets/business_type_selector.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/dividers/cus_divider_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

import '../../controller/ui_controller.dart';

class GeneralSettingsScreen extends StatelessWidget {
  static const String routeName = '/general_settings';

  const GeneralSettingsScreen({super.key});

  Future<void> _showEditShopInfoDialog(
    BuildContext context,
    String field,
    String currentValue,
  ) async {
    final ctrl = TextEditingController(text: currentValue);
    final cubit = context.read<ShopInfoCubit>();
    final label = _fieldLabel(field);

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $label'),
        content: TextField(
          controller: ctrl,
          maxLines: field == 'shopAddress' || field == 'noReturnNote' ? 3 : 1,
          decoration: InputDecoration(labelText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      switch (field) {
        case 'shopName':
          await cubit.updateShopName(result);
          break;
        case 'shopAddress':
          await cubit.updateShopAddress(result);
          break;
        case 'phNum':
          await cubit.updatePhNum(result);
          break;
        case 'noReturnNote':
          await cubit.updateNoReturnNote(result);
          break;
      }
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      ctrl.dispose();
    });
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'shopName':
        return 'Shop Name';
      case 'shopAddress':
        return 'Address';
      case 'phNum':
        return 'Phone Number';
      case 'noReturnNote':
        return 'No Return Note';
      default:
        return field;
    }
  }

  Future<void> _pickShopLogo(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final supportDir = await getApplicationSupportDirectory();
      final logoDir = Directory('${supportDir.path}/shop_logo');
      await logoDir.create(recursive: true);

      final ext = picked.path.split('.').last.toLowerCase();
      final destPath = '${logoDir.path}/logo.$ext';
      await File(picked.path).copy(destPath);

      if (!context.mounted) return;
      await context.read<ShopInfoCubit>().updateLogoPath(destPath);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save logo: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showChangeOwnerPasswordDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Change Owner Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                ),
              ),
              const SizedBox(height: UIConstants.mediumSpace),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              const SizedBox(height: UIConstants.mediumSpace),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final msg = await context
                    .read<UserDataCubit>()
                    .changeOwnerPassword(
                      currentPassword: currentController.text.trim(),
                      newPassword: newController.text.trim(),
                      confirmPassword: confirmController.text.trim(),
                    );

                if (!context.mounted) return;
                Navigator.of(ctx).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      msg ?? 'Owner password updated successfully.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      currentController.dispose();
      newController.dispose();
      confirmController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final currentUser = context.watch<UserDataCubit>().state.userModel;
    final bool isOwner =
        currentUser?.userLevel == UserLevel.merchant ||
        currentUser?.userLevel == UserLevel.superAdmin;
    final ShopInfoState shopInfoState = context.watch<ShopInfoCubit>().state;
    final accent = uiController.accentColor();

    Widget sectionHeader(String title, IconData icon) {
      return Padding(
        padding: const EdgeInsets.only(
          top: UIConstants.bigSpace,
          bottom: UIConstants.mediumSpace,
        ),
        child: Row(
          children: [
            Icon(icon, color: accent, size: UIConstants.bigIcon),
            const SizedBox(width: UIConstants.mediumSpace),
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(color: accent),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        centerTitle: true,
        title: const Text('General Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.bigSpace),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isOwner) ...[
                // ── Owner Security ──
                sectionHeader('Owner Security', Icons.lock_outline),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showChangeOwnerPasswordDialog(context),
                    icon: const Icon(Icons.key_outlined),
                    label: const Text('Change Owner Password'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: UIConstants.mediumSpace,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                const CusDividerWidget(clr: Colors.grey),

                // ── Printing Preferences ──
                sectionHeader('Printing Preferences', Icons.print_outlined),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Include QR Code in Voucher'),
                  subtitle: const Text(
                    'Print a QR code on receipts when available',
                  ),
                  value: shopInfoState.includeQrCode,
                  onChanged: (val) =>
                      context.read<ShopInfoCubit>().updateIncludeQrCode(val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Include Logo in Voucher'),
                  subtitle: const Text(
                    'Print shop logo on receipts if configured',
                  ),
                  value: shopInfoState.includeLogo,
                  onChanged: (val) =>
                      context.read<ShopInfoCubit>().updateIncludeLogo(val),
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                const CusDividerWidget(clr: Colors.grey),

                // ── Business Type ──
                sectionHeader('Business Type', Icons.category_outlined),
                BusinessTypeInfoCard(businessType: shopInfoState.businessType),
                const SizedBox(height: UIConstants.mediumSpace),
                BusinessTypeSelector(
                  selected: shopInfoState.businessType,
                  compact: true,
                  onChanged: (type) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Change Business Type?'),
                        content: Text(
                          'Switch to ${type.displayName}? Existing items keep their data. Theme and item fields will update.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Confirm'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await context.read<ShopInfoCubit>().updateBusinessType(
                        type,
                      );
                    }
                  },
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                const CusDividerWidget(clr: Colors.grey),

                // ── Shop Information ──
                sectionHeader('Shop Information', Icons.store_outlined),
                _InfoTile(
                  label: 'Shop Name',
                  value: shopInfoState.shopName,
                  onEdit: () => _showEditShopInfoDialog(
                    context,
                    'shopName',
                    shopInfoState.shopName,
                  ),
                ),
                _InfoTile(
                  label: 'Address',
                  value: shopInfoState.shopAddress,
                  onEdit: () => _showEditShopInfoDialog(
                    context,
                    'shopAddress',
                    shopInfoState.shopAddress,
                  ),
                ),
                _InfoTile(
                  label: 'Phone',
                  value: shopInfoState.phNum,
                  onEdit: () => _showEditShopInfoDialog(
                    context,
                    'phNum',
                    shopInfoState.phNum,
                  ),
                ),
                _InfoTile(
                  label: 'No Return Note',
                  value: shopInfoState.noReturnNote,
                  onEdit: () => _showEditShopInfoDialog(
                    context,
                    'noReturnNote',
                    shopInfoState.noReturnNote,
                  ),
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                const CusDividerWidget(clr: Colors.grey),

                // ── Shop Logo ──
                sectionHeader('Shop Logo', Icons.image_outlined),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LogoImageWidget(
                      widthandheight: 72 * shopInfoState.logoSizeRatio,
                      customLogoPath: shopInfoState.logoPath,
                    ),
                    const SizedBox(width: UIConstants.bigSpace),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickShopLogo(context),
                          icon: const Icon(Icons.image_outlined, size: 18),
                          label: const Text('Pick Logo'),
                        ),
                        if (shopInfoState.logoPath != null)
                          TextButton.icon(
                            onPressed: () => context
                                .read<ShopInfoCubit>()
                                .updateLogoPath(null),
                            icon: Icon(
                              Icons.restore,
                              color: Colors.grey.shade600,
                              size: 18,
                            ),
                            label: Text(
                              'Reset to Default',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: UIConstants.mediumSpace),
                Row(
                  children: [
                    const Text('Logo Size Ratio: '),
                    const SizedBox(width: UIConstants.smallSpace),
                    Text(
                      shopInfoState.logoSizeRatio.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  min: 0.5,
                  max: 3.0,
                  divisions: 25,
                  value: shopInfoState.logoSizeRatio.clamp(0.5, 3.0),
                  label: shopInfoState.logoSizeRatio.toStringAsFixed(1),
                  onChanged: (val) {
                    context.read<ShopInfoCubit>().updateLogoSizeRatio(val);
                  },
                ),
                const SizedBox(height: UIConstants.bigSpace),
              ] else ...[
                // Non-owner: only read-only shop info
                sectionHeader('Shop Information', Icons.store_outlined),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.mediumSpace,
                  ),
                  child: Text(
                    'Shop Name: ${shopInfoState.shopName}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.mediumSpace,
                  ),
                  child: Text(
                    'Address: ${shopInfoState.shopAddress}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: UIConstants.mediumSpace,
                  ),
                  child: Text(
                    'Phone: ${shopInfoState.phNum}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: UIConstants.bigSpace),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.smallSpace),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
