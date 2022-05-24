import 'dart:async';

import 'package:alfred/alfred.dart';
import 'package:alfredito/src/validators/validators.dart';
import 'package:meta/meta.dart';

part 'controller.dart';
part 'middleware.dart';

/// {@template route_handler}
/// A Route Handler is a class that can be registered as a callback.
/// {@endtemplate}
abstract class RouteHandler<T extends RouteHandler<T>> {
  /// {@macro route_handler_variables}
  ///
  /// Here you can define all your variables that will be available in the
  /// route handler.
  FutureOr<dynamic> defineVars(HttpRequest req, HttpResponse res) async {}

  /// this is the method that is called when the route is called
  FutureOr<dynamic> call(HttpRequest req, HttpResponse res) async {
    final instance = newInstance;
    // this handles the request
    await instance.defineVars(req, res);
    req.validate();
    await instance.run(req, res);
  }

  /// {@macro route_handler_variables}
  ///
  /// This is the callback that is called when the route is called.
  ///
  FutureOr<dynamic> run(HttpRequest req, HttpResponse res);

  /// this is the method that is called when the route is called
  T get newInstance;
}
