import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shows an iOS-style modal bottom sheet that can be smoothly dismissed
/// by swiping down anywhere on the sheet (headers, handles, backgrounds,
/// and scrollable content when at the top offset).
///
/// Centralizes modal bottom sheet configuration and behavior across the entire app.
Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  Color backgroundColor = Colors.transparent,
  bool useRootNavigator = true,
  bool enableDrag = true,
  RouteSettings? routeSettings,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    enableDrag: enableDrag,
    routeSettings: routeSettings,
    builder: (modalContext) => AppModalSheetWrapper(
      builder: builder,
    ),
  );
}

/// A wrapper widget providing iOS-style interactive swipe-down to dismiss.
/// Connects directly to the underlying [ModalBottomSheetRoute]'s animation controller
/// so that inner scroll overscroll seamlessly drives the native sheet dismissal
/// without any jumping, glitches, or duplicate pop animations.
class AppModalSheetWrapper extends StatefulWidget {
  final Widget? child;
  final WidgetBuilder? builder;
  final VoidCallback? onDismiss;

  const AppModalSheetWrapper({
    super.key,
    this.child,
    this.builder,
    this.onDismiss,
  }) : assert(child != null || builder != null, 'Provide either child or builder');

  @override
  State<AppModalSheetWrapper> createState() => _AppModalSheetWrapperState();
}

class _AppModalSheetWrapperState extends State<AppModalSheetWrapper> {
  bool _isDragging = false;
  bool _dismissUnderway = false;

  AnimationController? get _routeController {
    final route = ModalRoute.of(context);
    // ignore: invalid_use_of_protected_member
    return route?.controller;
  }

  double get _sheetHeight {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && renderBox.size.height > 0) {
      return renderBox.size.height;
    }
    return MediaQuery.of(context).size.height * 0.85;
  }

  void _unfocusIfNeeded() {
    if (FocusManager.instance.primaryFocus?.hasFocus == true) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (_dismissUnderway) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    final controller = _routeController;
    if (controller == null) return false;

    if (notification is ScrollStartNotification) {
      if (notification.dragDetails != null) {
        _unfocusIfNeeded();
        if (controller.isAnimating) {
          controller.stop();
        }
        _isDragging = true;
      }
    } else if (notification is OverscrollNotification) {
      // Inner list reached top (pixels == 0) and user drags down
      if (notification.overscroll < 0 && _isDragging) {
        final dy = notification.dragDetails?.delta.dy ?? (-notification.overscroll);
        if (dy > 0) {
          final height = _sheetHeight;
          final newProgress = math.max(0.0, controller.value - (dy / height));
          controller.value = newProgress;
        }
      }
    } else if (notification is ScrollUpdateNotification) {
      // 1. If currently pulled down (controller.value < 1.0) and user moves finger back UP
      if (controller.value < 1.0 && notification.scrollDelta != null) {
        final delta = notification.scrollDelta!;
        if (delta > 0) {
          // Scrolling down into content / finger moving up
          final height = _sheetHeight;
          final newProgress = math.min(1.0, controller.value + (delta / height));
          controller.value = newProgress;
        }
      }
      // 2. If inner list is bouncing past top boundary (Bouncing physics: pixels < 0)
      if (_isDragging &&
          notification.metrics.pixels < 0 &&
          notification.scrollDelta != null &&
          notification.scrollDelta! < 0) {
        final dy = -notification.scrollDelta!;
        final height = _sheetHeight;
        final newProgress = math.max(0.0, controller.value - (dy / height));
        controller.value = newProgress;
      }
    } else if (notification is ScrollEndNotification) {
      if (_isDragging) {
        _isDragging = false;
        final velocity = notification.dragDetails?.velocity.pixelsPerSecond.dy ?? 0.0;
        final height = _sheetHeight;
        var isClosing = false;

        // Dismiss if velocity flick is downwards (> 600 px/s) or dragged past ~15-18% threshold
        if (velocity > 600.0) {
          final flingVelocity = -velocity / height;
          if (controller.value > 0.0) {
            controller.fling(velocity: flingVelocity);
          }
          if (flingVelocity < 0.0) {
            isClosing = true;
          }
        } else if (controller.value < 0.85) {
          if (controller.value > 0.0) {
            controller.fling(velocity: -1.0);
          }
          isClosing = true;
        } else {
          controller.forward();
        }

        if (isClosing && !_dismissUnderway) {
          _dismissUnderway = true;
          if (widget.onDismiss != null) {
            widget.onDismiss!();
          } else {
            Navigator.of(context).pop();
          }
        }
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.child ?? widget.builder!(context);

    // Provide clamping physics to inner scrollables by default so downward drag
    // at the top immediately transitions into sheet dismissal without bouncing.
    final scrollConfigured = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        overscroll: false,
      ),
      child: content,
    );

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: scrollConfigured,
    );
  }
}

/// A universal, pre-styled modal bottom sheet container widget.
/// Can be used as a standardized wrapper for sheet content with iOS styling.
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? headerTrailing;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final bool showHandle;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.headerTrailing,
    this.height,
    this.constraints,
    this.padding,
    this.showHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    Widget body = child;

    return Container(
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: padding ?? EdgeInsets.only(bottom: bottomInset + safeBottom),
      child: Column(
        mainAxisSize: height != null ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showHandle) ...[
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  headerTrailing ??
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close_rounded, color: AppColors.textMuted),
                        iconSize: 22,
                        visualDensity: VisualDensity.compact,
                      ),
                ],
              ),
            ),
          ],
          Expanded(child: body),
        ],
      ),
    );
  }
}
