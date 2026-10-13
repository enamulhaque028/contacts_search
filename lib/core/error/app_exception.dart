/// The only errors a data source should throw. A real API client maps its
/// own errors (Dio, sockets, status codes) to one of these.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'No connection. Check your internet and try again.',
  ]);
}

class ServerException extends AppException {
  const ServerException({
    this.statusCode,
    String message = 'Server error. Please try again later.',
  }) : super(message);

  final int? statusCode;
}
