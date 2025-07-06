import 'package:shelf/shelf.dart';

// ANSI color codes
const _reset = '\x1B[0m';
const _red = '\x1B[31m';
const _green = '\x1B[32m';
const _yellow = '\x1B[33m';
const _blue = '\x1B[34m';
const _magenta = '\x1B[35m';
const _cyan = '\x1B[36m';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final startTime = DateTime.now();
      final method = request.method;
      final path = request.requestedUri.path;

      // Colorize HTTP methods
      String coloredMethod;
      switch (method) {
        case 'GET':
          coloredMethod = '$_green$method$_reset';
        case 'POST':
          coloredMethod = '$_blue$method$_reset';
        case 'PUT':
          coloredMethod = '$_yellow$method$_reset';
        case 'DELETE':
          coloredMethod = '$_red$method$_reset';
        default:
          coloredMethod = '$_magenta$method$_reset';
      }

      // Log request start
      print(
        '$_cyan[${startTime.toIso8601String()}]$_reset '
        '$coloredMethod $_cyan$path$_reset - ${_yellow}Started$_reset',
      );

      try {
        final response = await innerHandler(request);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Colorize status codes
        final statusCode = response.statusCode;
        String coloredStatus;
        if (statusCode >= 200 && statusCode < 300) {
          coloredStatus = '$_green$statusCode$_reset';
        } else if (statusCode >= 400 && statusCode < 500) {
          coloredStatus = '$_yellow$statusCode$_reset';
        } else if (statusCode >= 500) {
          coloredStatus = '$_red$statusCode$_reset';
        } else {
          coloredStatus = '$_cyan$statusCode$_reset';
        }

        // Log successful response
        print(
          '$_cyan[${endTime.toIso8601String()}]$_reset '
          '$coloredMethod $_cyan$path$_reset - '
          '${_green}Completed$_reset '
          '($_magenta${duration.inMilliseconds}ms$_reset) '
          'Status: $coloredStatus',
        );

        return response;
      } catch (e, stackTrace) {
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Log error
        print(
          '$_cyan[${endTime.toIso8601String()}]$_reset '
          '$coloredMethod $_cyan$path$_reset - '
          '${_red}Error$_reset '
          '($_magenta${duration.inMilliseconds}ms$_reset)\n'
          '${_red}Error: $e$_reset\n'
          '${_red}Stack Trace: $stackTrace$_reset',
        );

        rethrow;
      }
    };
  };
}
