import 'package:dispatcher/route/route_aware.dart';
import 'package:flutter/material.dart';

class MainRoute<T> extends MaterialPageRoute<T> {
  MainRoute(
    Widget widget, {
    RouteSettings settings,
  }) : super(
          builder: (_) => RouteAwareWidget(child: widget),
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      FadeTransition(
        opacity: animation,
        child: child,
      );
}

class SlideLeftRoute<T> extends MaterialPageRoute<T> {
  SlideLeftRoute(
    Widget widget, {
    RouteSettings settings,
  }) : super(
          builder: (_) => RouteAwareWidget(child: widget),
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        transformHitTests: false,
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-1.0, 0.0),
          ).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOut,
            ),
          ),
          child: child,
        ),
      );
}

class SlideUpRoute<T> extends MaterialPageRoute<T> {
  SlideUpRoute(
    Widget widget, {
    RouteSettings settings,
  }) : super(
          builder: (_) => RouteAwareWidget(child: widget),
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
        ),
        child: child,
      );
}

class ScaleRoute<T> extends MaterialPageRoute<T> {
  ScaleRoute(
    Widget widget, {
    RouteSettings settings,
  }) : super(
          builder: (_) => RouteAwareWidget(child: widget),
          settings: settings,
        );

  @override
  Duration get transitionDuration => const Duration(milliseconds: 500);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Interval(
              0.00,
              0.50,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 1.5,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Interval(
                0.50,
                1.00,
                curve: Curves.easeOut,
              ),
            ),
          ),
          child: child,
        ),
      );
}
