import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget that wraps scrollable content and handles nav bar auto-hide
///
/// Can be temporarily disabled during programmatic scrolls to prevent
/// unwanted navbar hiding.
///
/// Usage:
/// ```dart
/// final wrapperKey = GlobalKey<_NavScrollWrapperState>();
/// NavScrollWrapper(
///   key: wrapperKey,
///   child: ListView.builder(...),
/// )
///
/// // Disable during programmatic scroll
/// wrapperKey.currentState?.setEnabled(false);
/// await scrollController.animateTo(...);
/// wrapperKey.currentState?.setEnabled(true);
/// ```
class NavScrollWrapper extends StatefulWidget {
  final Widget child;

  const NavScrollWrapper({super.key, required this.child});

  @override
  State<NavScrollWrapper> createState() => NavScrollWrapperState();
}

class NavScrollWrapperState extends State<NavScrollWrapper> {
  double _lastScrollOffset = 0;
  bool _isProgrammaticScroll = false;

  /// Marks the start of a programmatic scroll
  void beginProgrammaticScroll() {
    _isProgrammaticScroll = true;
  }

  /// Marks the end of a programmatic scroll
  void endProgrammaticScroll() {
    // Simply flip the flag - position is already tracked during scroll
    _isProgrammaticScroll = false;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;

    final metrics = notification.metrics;
    final currentOffset = metrics.pixels;

    // During programmatic scrolls, track position but don't trigger navbar changes
    if (_isProgrammaticScroll) {
      _lastScrollOffset = currentOffset;
      return false;
    }

    // Check if NavCubit is available (it won't be on sub-routes like budget details)
    final navCubit = context.read<NavCubit?>();
    if (navCubit == null) return false; // Gracefully handle missing NavCubit

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
      navCubit.setNavBarVisible(false);
    } else if (!isScrollingDown && currentOffset > 0) {
      // Show when explicitly scrolling up (not at top)
      navCubit.setNavBarVisible(true);
    } else if (currentOffset <= 0) {
      // Always show when at the very top
      navCubit.setNavBarVisible(true);
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
