import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:shelf/shelf.dart';

Middleware authMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['Authorization'];

      // Helper function to create JSON error responses
      Response jsonErrorResponse(int statusCode, Map<String, dynamic> body) {
        return Response(
          statusCode,
          body: json.encode(body),
          headers: {'Content-Type': 'application/json'},
        );
      }

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return jsonErrorResponse(401, {
          "success": false,
          "message":
              "Authentication required. Please provide a valid bearer token 123.",
          "data": null,
        });
      }

      try {
        final token = authHeader.substring(7);
        final jwt = JWT.verify(token, SecretKey('your-secret-key'));
        final userId = jwt.payload['userId'] as String;

        return innerHandler(request.change(context: {'userId': userId}));
      } on JWTExpiredException {
        return jsonErrorResponse(401, {
          "success": false,
          "message": "Token has expired. Please log in again.",
          "data": null,
        });
      } on JWTException catch (e) {
        return jsonErrorResponse(401, {
          "success": false,
          "message": "Invalid token: ${e.message}",
          "data": null,
        });
      } catch (e) {
        return jsonErrorResponse(500, {
          "success": false,
          "message": "Authentication failed. Please try again.",
          "data": null,
        });
      }
    };
  };
}
