import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that wraps scrollable content and handles nav bar auto-hide
///
/// Usage:
/// ```dart
/// NavScrollWrapper(
///   child: ListView.builder(...),
/// )
/// ```
class NavScrollWrapper extends StatefulWidget {
  final Widget child;

  const NavScrollWrapper({super.key, required this.child});

  @override
  State<NavScrollWrapper> createState() => _NavScrollWrapperState();
}

class _NavScrollWrapperState extends State<NavScrollWrapper> {
  double _lastScrollOffset = 0;

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;

    final metrics = notification.metrics;
    final currentOffset = metrics.pixels;
    final scrollDelta = currentOffset - _lastScrollOffset;

    // Ignore tiny scroll movements
    if (scrollDelta.abs() < 5) return false;

    // Ignore overscroll bounce-back (at top or bottom edges)
    final isAtTop = currentOffset <= metrics.minScrollExtent;
    final isAtBottom = currentOffset >= metrics.maxScrollExtent;
    final isBouncingBack = (isAtTop && scrollDelta > 0) ||
                           (isAtBottom && scrollDelta < 0);

    if (isBouncingBack) return false;

    _lastScrollOffset = currentOffset;

    final isScrollingDown = scrollDelta > 0;

    if (isScrollingDown && currentOffset > 50) {
      // Hide immediately when scrolling down
      context.read<NavCubit>().setNavBarVisible(false);
    } else if (!isScrollingDown && currentOffset > 0) {
      // Show when explicitly scrolling up (not at top)
      context.read<NavCubit>().setNavBarVisible(true);
    } else if (currentOffset <= 0) {
      // Always show when at the very top
      context.read<NavCubit>().setNavBarVisible(true);
    }

    return false; // Don't absorb the notification
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: widget.child,
    );
  }
}
