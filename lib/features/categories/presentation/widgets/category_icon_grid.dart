import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:flutter/material.dart';

/// Grid of selectable category icons
///
/// V4 Styling:
/// - 6 columns
/// - 14px spacing (both axes)
/// - 190px height
/// - 2px borders
/// - 8px border radius
/// - Selected: onSurface border, surface.withAlpha(25) background
/// - Unselected: outlineVariant border, transparent background
class CategoryIconGrid extends StatelessWidget {
  final List<String> iconNames;
  final String? selectedIconName;
  final Function(String) onIconTap;

  const CategoryIconGrid({
    super.key,
    required this.iconNames,
    this.selectedIconName,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 190, // v4 exact
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6, // v4: 6 columns
          crossAxisSpacing: 14, // v4 exact
          mainAxisSpacing: 14, // v4 exact
        ),
        itemCount: iconNames.length,
        itemBuilder: (context, index) {
          final iconName = iconNames[index];
          final isSelected = iconName == selectedIconName;

          return GestureDetector(
            onTap: () => onIconTap(iconName),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.outlineVariant,
                  width: 2, // v4 exact
                ),
                borderRadius: BorderRadius.circular(8), // v4 exact
                color: isSelected
                    ? theme.colorScheme.surface.withValues(alpha: 25 / 255)
                    : Colors.transparent,
              ),
              child: Icon(
                _getIconData(iconName),
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Map iconName string to TablerIcons
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shoppingCart':
        return TablerIcons.shoppingCart;
      case 'toolsKitchen2':
        return TablerIcons.toolsKitchen2;
      case 'home':
        return TablerIcons.home;
      case 'car':
        return TablerIcons.car;
      case 'firstAidKit':
        return TablerIcons.firstAidKit;
      case 'deviceTv':
        return TablerIcons.deviceTv;
      case 'wallet':
        return TablerIcons.wallet;
      case 'coffee':
        return TablerIcons.coffee;
      case 'gas':
        return TablerIcons.car; // Fallback to car icon
      case 'shirt':
        return TablerIcons.shirt;
      case 'plane':
        return TablerIcons.plane;
      case 'book':
        return TablerIcons.book;
      case 'dumbbell':
        return TablerIcons.barbell;
      case 'gift':
        return TablerIcons.gift;
      case 'heart':
        return TablerIcons.heart;
      case 'phone':
        return TablerIcons.phone;
      case 'laptop':
        return TablerIcons.deviceLaptop;
      case 'music':
        return TablerIcons.music;
      case 'camera':
        return TablerIcons.camera;
      case 'briefcase':
        return TablerIcons.briefcase;
      case 'creditCard':
        return TablerIcons.creditCard;
      case 'piggyBank':
        return TablerIcons.wallet; // Fallback to wallet icon
      case 'receipt':
        return TablerIcons.receipt;
      default:
        return TablerIcons.category;
    }
  }
}
