part of 'route_handler.dart';

/// {@template route_handler}
/// A Route Handler is a class that can be registered as a callback.
/// {@endtemplate}
///
abstract class Controller<T extends RouteHandler<T>> with RouteHandler<T> {
  /// {@macro route_handler}
  ///
  @literal
  const Controller();
}
