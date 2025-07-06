import 'package:shelf/shelf.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip auth for certain paths
      if (request.url.path.startsWith('public/')) {
        return innerHandler(request);
      }

      // Get auth header
      final authHeader = request.headers['Authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(401, body: 'Unauthorized');
      }

      // Validate token (in a real app, you'd verify JWT or similar)
      final token = authHeader.substring(7);
      if (token.isEmpty) {
        return Response(401, body: 'Unauthorized');
      }

      // Add user info to request context
      final updatedRequest = request.change(
        context: {
          ...request.context,
          'user': {'id': '123', 'token': token},
        },
      );

      return innerHandler(updatedRequest);
    };
  };
}
