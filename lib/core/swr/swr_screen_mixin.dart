import 'package:flutter/widgets.dart';
import 'swr_event_bus.dart';

/// Global RouteObserver for SWR screens to detect when routes are popped
/// and the screen becomes visible again.
final RouteObserver<ModalRoute<void>> swrRouteObserver = RouteObserver<ModalRoute<void>>();

/// Mixin for [StatefulWidget] states that automatically triggers
/// SWR background revalidation when:
/// 1. The screen is first mounted (initial navigation).
/// 2. The user switches to this screen's tab in [AppScaffold] (via [swrTabIndex]).
/// 3. The user pops back to this screen from a pushed route / dialog ([didPopNext]).
/// 4. The app is resumed from background ([AppLifecycleState.resumed]).
mixin SwrScreenMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver, RouteAware {
  /// Optional tab index if this screen lives inside [AppScaffold] / [StatefulShellRoute].
  int? get swrTabIndex => null;

  /// Callback to execute when revalidation should occur.
  void onRevalidate();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. Initial screen mount revalidate (post frame to ensure ref/context is ready)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        onRevalidate();
      }
    });

    // 2. Listen to tab activation events if a tab index is specified
    final tabIndex = swrTabIndex;
    if (tabIndex != null) {
      SwrEventBus.instance.addListener('app:tab:$tabIndex', _onSwrTabActivated);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      swrRouteObserver.subscribe(this, modalRoute);
    }
  }

  void _onSwrTabActivated(dynamic _) {
    if (mounted) {
      onRevalidate();
    }
  }

  @override
  void didPopNext() {
    // Called when a top route has been popped off, and this route shows up again.
    if (mounted) {
      onRevalidate();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Revalidate when user returns to app from background / unlock
    if (state == AppLifecycleState.resumed && mounted) {
      onRevalidate();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    swrRouteObserver.unsubscribe(this);
    final tabIndex = swrTabIndex;
    if (tabIndex != null) {
      SwrEventBus.instance.removeListener('app:tab:$tabIndex', _onSwrTabActivated);
    }
    super.dispose();
  }
}
