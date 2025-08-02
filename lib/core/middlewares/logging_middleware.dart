import 'package:shelf/shelf.dart';

// ANSI color codes
const reset = '\x1B[0m';
const red = '\x1B[31m';
const green = '\x1B[32m';
const yellow = '\x1B[33m';
const blue = '\x1B[34m';
const magenta = '\x1B[35m';
const cyan = '\x1B[36m';

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
          coloredMethod = '$green$method$reset';
        case 'POST':
          coloredMethod = '$blue$method$reset';
        case 'PUT':
          coloredMethod = '$yellow$method$reset';
        case 'DELETE':
          coloredMethod = '$red$method$reset';
        default:
          coloredMethod = '$magenta$method$reset';
      }

      // Log request start
      print(
        '$cyan[${startTime.toIso8601String()}]$reset '
        '$coloredMethod $cyan$path$reset - ${yellow}Started$reset',
      );

      try {
        final response = await innerHandler(request);
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Colorize status codes
        final statusCode = response.statusCode;
        String coloredStatus;
        if (statusCode >= 200 && statusCode < 300) {
          coloredStatus = '$green$statusCode$reset';
        } else if (statusCode >= 400 && statusCode < 500) {
          coloredStatus = '$yellow$statusCode$reset';
        } else if (statusCode >= 500) {
          coloredStatus = '$red$statusCode$reset';
        } else {
          coloredStatus = '$cyan$statusCode$reset';
        }

        // Log successful response
        print(
          '$cyan[${endTime.toIso8601String()}]$reset '
          '$coloredMethod $cyan$path$reset - '
          '${green}Completed$reset '
          '($magenta${duration.inMilliseconds}ms$reset) '
          'Status: $coloredStatus',
        );

        return response;
      } catch (e, stackTrace) {
        final endTime = DateTime.now();
        final duration = endTime.difference(startTime);

        // Log error
        print(
          '$cyan[${endTime.toIso8601String()}]$reset '
          '$coloredMethod $cyan$path$reset - '
          '${red}Error$reset '
          '($magenta${duration.inMilliseconds}ms$reset)\n'
          '${red}Error: $e$reset\n'
          '${red}Stack Trace: $stackTrace$reset',
        );

        rethrow;
      }
    };
  };
}

log(String msg) => print('$cyan[dev] $msg$reset');
serverLog(String msg) => print('$green[server] $msg$reset');
