import 'package:alfred/alfred.dart';
import 'package:alfredito/src/validators/validators.dart';

/// {@template alfredito}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class Alfredito extends Alfred {
  /// {@macro alfredito}
  Alfredito({
    super.onNotFound,
    super.onInternalError,
    super.logLevel,
    super.simultaneousProcessing,
  }) {
    registerOnDoneListener(errorPluginOnDoneHandler);
  }

  /// A method to register route handlers.
  void registerRoutes(List<HttpRoute> routes) => routes.addAll(routes);
}
