import 'package:flutter/material.dart';

import 'web_history.dart';

/// Keeps Flutter's imperative Navigator and the browser address bar in sync.
///
/// Without this observer, Navigator.pushNamed changes the in-app stack but
/// the browser can remain at `/#/`, so a browser reload starts at the login
/// check route instead of the page the user was viewing.
class WebRouteObserver extends NavigatorObserver {
  void _updateBrowserLocation(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    updateWebHistory(name, replace: true);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateBrowserLocation(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _updateBrowserLocation(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _updateBrowserLocation(previousRoute);
  }
}
