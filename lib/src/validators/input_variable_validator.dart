// ignore_for_file: no_duplicate_case_values

part of 'validators.dart';

/// {@template source}
/// Enum for the different types of input variables.
/// {@endtemplate}
enum Source {
  /// when the input variable is a body parameter
  body,

  /// when the input variable is a query parameter
  query,

  /// when the input variable is a header parameter
  headers,
}

/// {@template error_type}
/// Enum for the different types of errors.
///
/// The [ErrorType] is used to specify the type of error that occurred during
/// the validation of a request.
/// {@endtemplate}
enum ErrorType {
  /// the input variable is required and was not provided
  parameterNotFound,

  /// the input variable was found but the type did not match with
  /// the expected type
  parameterTypeMismatch,

  /// the input variable was found but the value did not match with
  /// the regular expression provided
  customValidationFailed,
}

/// {@template input_variable_validator}
/// An [InputVariableValidator] is a class that validates an input variable.
///
/// It is used to validate the input variables of a request.
/// {@endtemplate}
class InputVariableValidator<T> {
  /// {@macro input_variable_validator}
  InputVariableValidator(
    this.req,
    this.name, {
    this.source = Source.body,
    this.regExp,
    this.regExpErrorMessage,
    this.onEmpty,
  });

  /// the name of the parameter to be found and validated
  final String name;

  /// where the variable should be found
  final Source source;

  /// the request
  final HttpRequest req;

  /// the regular expression to validate the input variable
  final RegExp? regExp;

  /// the error message to be returned when the regular expression fails
  final String? regExpErrorMessage;

  /// the function to be called when the input variable is empty
  final T? onEmpty;

  /// {@macro input_variable_validator}
  /// {@endtemplate}
  Future<T> required() async {
    dynamic value;
    try {
      value = await _parseParameter();
    } catch (_) {
      throw AlfredException(400, {
        'message': 'Empty body',
      });
    }

    if (value == null || (value is String && value.isEmpty)) {
      _addError(value, ErrorType.parameterNotFound);
      return _createInstanceOf();
    } else if ((T == num || T == int || T == double) && value is String) {
      final asNum = num.tryParse(value);
      if (asNum == null) {
        _addError(value, ErrorType.parameterTypeMismatch);
        return _createInstanceOf();
      }
      return asNum as T;
    } else if (value is! T) {
      _addError(value, ErrorType.parameterTypeMismatch);
      return _createInstanceOf();
    }

    if (value is String && regExp != null) {
      final isValid = regExp?.hasMatch(value) ?? true;
      if (!isValid) {
        _addError(value, ErrorType.customValidationFailed);
        return _createInstanceOf();
      }
    }

    return value;
  }

  /// {@macro input_variable_validator}
  /// {@endtemplate}
  Future<T?> optional() async {
    dynamic value;
    try {
      value = await _parseParameter();
    } catch (_) {
      return null;
    }

    if (value == null || (value is String && value.isEmpty)) {
      return null;
    } else if ((T == num || T == int || T == double) && value is String) {
      final asNum = num.tryParse(value);
      if (asNum == null) {
        _addError(value, ErrorType.parameterTypeMismatch);
        return null;
      }
      return asNum as T;
    } else if (value is! T) {
      _addError(value, ErrorType.parameterTypeMismatch);
      return null;
    }

    if (value is String && regExp != null) {
      final isValid = regExp?.hasMatch(value) ?? true;
      if (!isValid) {
        _addError(value, ErrorType.customValidationFailed);
        return null;
      }
    }

    return value;
  }

  FutureOr<dynamic> _parseParameter() async {
    dynamic value;
    switch (source) {
      case Source.body:
        final body = await req.bodyAsJsonMap;
        if (body.containsKey(name)) {
          value = body[name];
        }
        break;
      case Source.query:
        if (req.params.containsKey(name)) {
          value = req.params[name];
        }
        break;
      case Source.headers:
        if (req.headers.value(name) != null) {
          value = req.headers.value(name);
        }
        break;
    }
    return value;
  }

  void _addError(
    dynamic value,
    ErrorType errorType,
  ) {
    late final String errorMessage;
    switch (errorType) {
      case ErrorType.parameterNotFound:
        errorMessage = '$name is required';
        break;
      case ErrorType.customValidationFailed:
        errorMessage = regExpErrorMessage ?? 'validation failed';
        break;
      case ErrorType.parameterTypeMismatch:
        errorMessage = 'Parameter is not a valid $T';
        break;
    }
    req.errorStore.add(
      ValidationError(
        location: source.name,
        msg: errorMessage,
        param: name,
      ),
    );
  }

  T _createInstanceOf() {
    switch (T) {
      case String:
        return '' as T;
      case num:
        return 0 as T;
      case bool:
        return false as T;
      case DateTime:
        return DateTime.now() as T;
      case List:
        return <dynamic>[] as T;
      case Map:
        return <dynamic, dynamic>{} as T;
      default:
        return onEmpty!;
    }
  }
}
