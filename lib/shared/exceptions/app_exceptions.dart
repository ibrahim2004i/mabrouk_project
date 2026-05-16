class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  AppException(this.message, {this.code, this.data});

  @override
  String toString() => message;
}

class BookingConflictException extends AppException {
  final Map<String, dynamic> conflictData;

  BookingConflictException(String message, this.conflictData)
      : super(message, code: 'CONFLICT', data: conflictData);
}

class UnauthenticatedException extends AppException {
  UnauthenticatedException([super.message = 'loginRequiredMessage'])
      : super(code: 'UNAUTHENTICATED');
}

class NetworkException extends AppException {
  NetworkException([super.message = 'networkError'])
      : super(code: 'NETWORK_ERROR');
}
