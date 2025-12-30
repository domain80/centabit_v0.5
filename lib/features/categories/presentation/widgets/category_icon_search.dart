import 'package:flutter/material.dart';

/// Search input for filtering category icons
///
/// Simple TextField with consistent styling:
/// - 12px border radius (v4 exact)
/// - 1px border width
/// - Primary color on focus
/// - Optional clear button when text is entered
class CategoryIconSearch extends StatelessWidget {
  final Function(String) onSearchChanged;

  const CategoryIconSearch({
    super.key,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search icons...',
        hintStyle: const TextStyle(fontSize: 16),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // v4: 12px
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 80 / 255),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 80 / 255),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
