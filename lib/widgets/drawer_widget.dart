import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/uiConstants.dart';

class DrawerWidget extends StatelessWidget {

  final int index;
  final String txt;
  final VoidCallback func;
  final bool isSelected;
  const DrawerWidget({
    super.key,
    required this.index,
    required this.txt,
    required this.func,
    required this.isSelected,
  });

  /// Map page titles to appropriate icons
  IconData _getIconForPage(String title) {
    switch (title.toLowerCase()) {
      case 'dashboard':
        return Icons.dashboard_rounded;
      case 'stock out':
        return Icons.shopping_cart_checkout_rounded;
      case 'stock in':
        return Icons.inventory_2_rounded;
      case 'storage':
        return Icons.warehouse_rounded;
      case 'transaction history':
        return Icons.receipt_long_rounded;
      case 'history':
        return Icons.history_rounded;
      case 'tables and charts':
        return Icons.bar_chart_rounded;
      case 'promotions':
        return Icons.local_offer_rounded;
      case 'settings':
        return Icons.settings_rounded;
      case 'accounts':
        return Icons.people_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForPage(txt);

    return InkWell(
      splashColor: Colors.deepPurple.withValues(alpha: 0.1),
      borderRadius: UIConstants.mediumBorderRadius,
      onTap: func,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.mediumSpace,
          horizontal: UIConstants.bigSpace,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurple.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: UIConstants.mediumBorderRadius,
          border: isSelected
              ? Border.all(
                  color: Colors.deepPurple.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 3,
          horizontal: UIConstants.mediumSpace,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.deepPurple : Colors.grey,
            ),
            const SizedBox(width: UIConstants.mediumSpace + 2),
            Expanded(
              child: Text(
                txt,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Colors.deepPurple
                          : Theme.of(context).textTheme.bodyMedium!.color,
                    ),
              ),
            ),
            if (isSelected)
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
