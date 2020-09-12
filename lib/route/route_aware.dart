import 'package:flutter/material.dart';

final RouteObserver<PageRoute> appRouteObserver = RouteObserver<PageRoute>();

class RouteAwareWidget extends StatefulWidget {
  final Widget child;

  RouteAwareWidget({
    this.child,
  });

  State<RouteAwareWidget> createState() => RouteAwareWidgetState(child: child);
}

class RouteAwareWidgetState extends State<RouteAwareWidget> with RouteAware {
  final Widget child;

  RouteAwareWidgetState({
    this.child,
  });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appRouteObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator
    // StoreProvider.of<AppState>(context).dispatch(NavigatePopAction());
  }

  @override
  Widget build(
    BuildContext context,
  ) =>
      Container(child: child);
}
