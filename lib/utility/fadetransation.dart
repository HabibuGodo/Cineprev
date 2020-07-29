import 'package:flutter/material.dart';

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  // @override
  Widget buildTransition(BuildContext context, Animation<double> animation,
      Animation<double> secondAnimation, Widget child) {
    if (settings.isInitialRoute) {
      return child;
    }
    return FadeTransition(opacity: animation, child: child);
  }
}