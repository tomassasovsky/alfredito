part of 'validators.dart';

/// Data structure to keep all request-related data
final errorPluginData = <HttpRequest, ErrorStore>{};

/// Integrates [ErrorStore] mechanism on [HttpRequest]
extension ErrorPlugin on HttpRequest {
  /// Returns the [ErrorStore] dedicated to this request.
  ErrorStore get errorStore {
    errorPluginData[this] ??= ErrorStore();
    return errorPluginData[this]!;
  }

  /// Returns the errors of this request, if any.
  void validate() {
    final errors = errorStore.jsonErrors;
    if (errors.isNotEmpty) {
      throw AlfredException(400, {
        'errors': errors,
      });
    }
  }
}

/// Data structure to keep all request-related data
class ErrorStore {
  /// Default constructor
  ErrorStore();

  final _errors = <ValidationError>[];

  /// Aggregates an error into the error list.
  void add(ValidationError error) => _errors.add(error);

  /// Returns the errors of this request, if any.
  List<ValidationError> get errors => _errors;

  /// Returns the errors of this request, if any.
  List<Map<String, dynamic>> get jsonErrors {
    return _errors.map((e) => e._toJson()).toList();
  }
}

/// handler for [ValidationError]
void errorPluginOnDoneHandler(HttpRequest req, HttpResponse res) {
  errorPluginData.remove(req);
}

/// {@template validation_error}
/// A [ValidationError] is a class that represents an error that occurred during
/// the validation of a request.
/// {@endtemplate}
class ValidationError {
  /// {@macro validation_error}
  /// A [ValidationError] is a class that represents an error that occurred
  /// during the validation of a request.
  /// {@endtemplate}
  ValidationError({
    this.location,
    this.msg,
    this.param,
  });

  Map<String, String> _toJson() {
    return <String, String>{
      if (location != null && (location?.isNotEmpty ?? false))
        'location': location!,
      if (msg != null && (msg?.isNotEmpty ?? false)) 'msg': msg!,
      if (param != null && (param?.isNotEmpty ?? false)) 'param': param!,
    };
  }

  /// The location of the parameter which gave the error.
  final String? location;

  /// The error message.
  final String? msg;

  /// The parameter that caused the error.
  final String? param;
}
