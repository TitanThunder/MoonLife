import 'package:flutter/widgets.dart';

extension GetArgument on BuildContext {
  T? getArgument<T>() {
    print("getArgument");
    final modalRoute = ModalRoute.of(this);
    if (modalRoute != null) {
      final args = modalRoute.settings.arguments;
      if (args != null && args is T) {
        return args as T;
      }
    }
    return null;
  }
}
