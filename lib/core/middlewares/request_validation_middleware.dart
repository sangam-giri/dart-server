import 'package:shelf/shelf.dart';
import 'dart:convert';

Middleware requestValidationMiddleware(Map<String, dynamic> schema) {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'POST' || request.method == 'PUT') {
        try {
          final body = await request.readAsString();
          final json = jsonDecode(body);

          // Simple validation - in a real app you'd use a proper validator
          for (final key in schema.keys) {
            if (schema[key] == 'required' && json[key] == null) {
              return Response(400, body: 'Missing required field: $key');
            }
          }

          // Add validated body to request context
          final validatedRequest = request.change(
            context: {...request.context, 'validatedBody': json},
          );

          return innerHandler(validatedRequest);
        } catch (e) {
          return Response(400, body: 'Invalid request body: ${e.toString()}');
        }
      }
      return innerHandler(request);
    };
  };
}
