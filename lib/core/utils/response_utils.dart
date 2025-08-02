import 'package:dart_server/core/models/base_model.dart';
import 'package:shelf/shelf.dart';
import 'dart:convert';

class ResponseUtils {
  static Response success(dynamic data, {int statusCode = 200}) {
    // Handle BaseModel objects
    if (data is BaseModel) {
      return _jsonResponse(data.toJson(), statusCode: statusCode);
    }
    // Handle lists of BaseModel objects
    else if (data is List && data.isNotEmpty && data.first is BaseModel) {
      return _jsonResponse(
        data.map((item) => (item as BaseModel).toJson()).toList(),
        statusCode: statusCode,
      );
    }
    // Handle other types
    else {
      return _jsonResponse(data, statusCode: statusCode);
    }
  }

  static Response error(String message, {int statusCode = 400}) {
    return _jsonResponse({
      'success': false,
      'error': message,
    }, statusCode: statusCode);
  }

  static Response notFound([String message = 'Resource not found']) {
    return error(message, statusCode: 404);
  }

  static Response serverError([String message = 'Internal server error']) {
    return error(message, statusCode: 500);
  }

  static Response _jsonResponse(dynamic data, {required int statusCode}) {
    return Response(
      statusCode,
      body: jsonEncode({'success': true, 'data': data}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
