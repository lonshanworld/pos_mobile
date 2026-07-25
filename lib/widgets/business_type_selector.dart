import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';

class BusinessItemDetailChips extends StatelessWidget {
  final BusinessType businessType;
  final ItemBusinessDetailModel? detail;
  final int maxLines;

  const BusinessItemDetailChips({
    super.key,
    required this.businessType,
    this.detail,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (businessType == BusinessType.general || detail == null) {
      return const SizedBox.shrink();
    }

    final lines = detail!.summaryLines(businessType);
    if (lines.isEmpty) return const SizedBox.shrink();

    final accent = UIController.instance.accentColor();
    final visible = lines.take(maxLines).toList();

    return Padding(
      padding: const EdgeInsets.only(top: UIConstants.smallSpace),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: visible
            .map(
              (line) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: UIConstants.smallBorderRadius,
                  border: Border.all(color: accent.withValues(alpha: 0.25)),
                ),
                child: Text(
                  line,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class BusinessTypeInfoCard extends StatelessWidget {
  final BusinessType businessType;
  final bool locked;

  const BusinessTypeInfoCard({
    super.key,
    required this.businessType,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = UIController.instance.accentColor();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.mediumSpace),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: UIConstants.mediumBorderRadius,
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(businessType.icon, color: accent),
              const SizedBox(width: UIConstants.mediumSpace),
              Expanded(
                child: Text(
                  businessType.displayName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (locked)
                Icon(Icons.lock_outline, size: 18, color: accent),
            ],
          ),
          const SizedBox(height: UIConstants.smallSpace),
          Text(
            businessType.shortDescription,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          if (locked) ...[
            const SizedBox(height: UIConstants.smallSpace),
            Text(
              'Locked for this app build — change kReleaseBusinessType in main.dart to ship a different flavor.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accent,
                    fontSize: 11,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class BusinessTypeSelector extends StatelessWidget {
  final BusinessType selected;
  final ValueChanged<BusinessType> onChanged;
  final bool compact;

  const BusinessTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = UIController.instance.accentColor();

    if (compact) {
      return DropdownButtonFormField<BusinessType>(
        value: selected,
        decoration: const InputDecoration(
          labelText: 'Business Type',
          border: OutlineInputBorder(borderRadius: UIConstants.mediumBorderRadius),
        ),
        items: BusinessType.values
            .map(
              (type) => DropdownMenuItem(
                value: type,
                child: Text(type.displayName),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: BusinessType.values.map((type) {
        final isSelected = type == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: UIConstants.smallSpace),
          child: Material(
            color: isSelected
                ? accent.withValues(alpha: 0.12)
                : Theme.of(context).cardTheme.color,
            borderRadius: UIConstants.mediumBorderRadius,
            child: InkWell(
              borderRadius: UIConstants.mediumBorderRadius,
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.all(UIConstants.mediumSpace),
                decoration: BoxDecoration(
                  borderRadius: UIConstants.mediumBorderRadius,
                  border: Border.all(
                    color: isSelected ? accent : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(type.icon, color: isSelected ? accent : Colors.grey),
                    const SizedBox(width: UIConstants.mediumSpace),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type.displayName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: isSelected ? accent : null,
                                ),
                          ),
                          Text(
                            type.shortDescription,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected) Icon(Icons.check_circle, color: accent),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
