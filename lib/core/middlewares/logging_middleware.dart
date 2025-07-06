import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final startTime = DateTime.now();
      final requestInfo = '${request.method} ${request.requestedUri.path}';

      // Log request
      print('[${startTime.toIso8601String()}] $requestInfo - Started');

      try {
        final response = await innerHandler(request);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Log successful response
        print(
          '[${endTime.toIso8601String()}] $requestInfo - Completed '
          '(${duration.inMilliseconds}ms) '
          'Status: ${response.statusCode}',
        );

        return response;
      } catch (e, stackTrace) {
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Log error
        print(
          '[${endTime.toIso8601String()}] $requestInfo - Error '
          '(${duration.inMilliseconds}ms)\n'
          'Error: $e\n'
          'Stack Trace: $stackTrace',
        );

        rethrow;
      }
    };
  };
}
