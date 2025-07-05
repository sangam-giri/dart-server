import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:dotenv/dotenv.dart';

class MongoDB {
  static late Db _db;
  static late DbCollection _itemsCollection;

  static Future<void> connect() async {
    final env = DotEnv(includePlatformEnvironment: true)..load();
    final uri = env['MONGODB_URI'] ?? 'mongodb://localhost:27017/dart_crud';

    _db = await Db.create(uri);
    await _db.open();
    _itemsCollection = _db.collection('items');
    print('Connected to MongoDB');
  }

  static Future<void> close() async {
    await _db.close();
  }

  static DbCollection get itemsCollection => _itemsCollection;
}

// Helper function to convert MongoDB document to JSON-serializable map
Map<String, dynamic> _convertMongoDocument(Map<String, dynamic>? doc) {
  if (doc == null) return {};

  final converted = Map<String, dynamic>.from(doc);

  // Convert ObjectId to string
  if (converted['_id'] is ObjectId) {
    converted['id'] = converted['_id'].toHexString();
    converted.remove('_id');
  }

  // Convert DateTime to ISO string
  converted.forEach((key, value) {
    if (value is DateTime) {
      converted[key] = value.toIso8601String();
    }
  });

  return converted;
}

void main(List<String> args) async {
  // Initialize MongoDB connection
  await MongoDB.connect();

  // Clean up on process exit
  ProcessSignal.sigint.watch().listen((_) async {
    await MongoDB.close();
    exit(0);
  });

  final app = Router();

  // Helper function for JSON responses
  Response _jsonResponse(dynamic data, {int statusCode = 200}) {
    return Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Create
  app.post('/items', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Remove ID if provided (MongoDB will generate its own)
      data.remove('id');

      // Add createdAt timestamp
      data['createdAt'] = DateTime.now().toUtc();

      final result = await MongoDB.itemsCollection.insertOne(data);

      if (result.isSuccess) {
        final insertedItem = await MongoDB.itemsCollection.findOne(
          where.id(result.id),
        );
        return _jsonResponse(
          _convertMongoDocument(insertedItem),
          statusCode: 201,
        );
      } else {
        return Response.internalServerError(body: 'Failed to create item');
      }
    } catch (e) {
      return Response.badRequest(body: 'Invalid request: $e');
    }
  });

  // Read all (with optional query parameters)
  app.get('/items', (Request request) async {
    try {
      final params = request.url.queryParameters;
      final query = <String, dynamic>{};

      if (params.containsKey('name')) {
        query['name'] = params['name'];
      }

      final items = await MongoDB.itemsCollection.find(query).toList();
      final convertedItems = items.map(_convertMongoDocument).toList();
      return _jsonResponse(convertedItems);
    } catch (e) {
      return Response.internalServerError(body: 'Failed to retrieve items: $e');
    }
  });

  // Read single
  app.get('/items/<id>', (Request request, String id) async {
    try {
      ObjectId itemId;
      try {
        itemId = ObjectId.fromHexString(id);
      } catch (e) {
        return Response.badRequest(body: 'Invalid ID format');
      }

      final item = await MongoDB.itemsCollection.findOne(where.id(itemId));

      if (item == null) {
        return Response.notFound('Item not found');
      }

      return _jsonResponse(_convertMongoDocument(item));
    } catch (e) {
      return Response.internalServerError(body: 'Failed to retrieve item: $e');
    }
  });

  // Update
  app.put('/items/<id>', (Request request, String id) async {
    try {
      ObjectId itemId;
      try {
        itemId = ObjectId.fromHexString(id);
      } catch (e) {
        return Response.badRequest(body: 'Invalid ID format');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Don't allow updating the ID
      data.remove('_id');
      data.remove('id');

      // Add updatedAt timestamp
      data['updatedAt'] = DateTime.now().toUtc();

      final result = await MongoDB.itemsCollection.updateOne(where.id(itemId), {
        '\$set': data,
      });

      if (result.isSuccess) {
        final updatedItem = await MongoDB.itemsCollection.findOne(
          where.id(itemId),
        );
        return _jsonResponse(_convertMongoDocument(updatedItem));
      } else {
        return Response.notFound('Item not found');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Failed to update item: $e');
    }
  });

  // Delete
  app.delete('/items/<id>', (Request request, String id) async {
    try {
      ObjectId itemId;
      try {
        itemId = ObjectId.fromHexString(id);
      } catch (e) {
        return Response.badRequest(body: 'Invalid ID format');
      }

      final result = await MongoDB.itemsCollection.deleteOne(where.id(itemId));

      if (result.isSuccess && result.nRemoved > 0) {
        return Response.ok('Item deleted');
      } else {
        return Response.notFound('Item not found');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Failed to delete item: $e');
    }
  });

  // Start server
  final server = await io.serve(app, '0.0.0.0', 8080);

  print('Server running on http://${server.address.host}:${server.port}');
}
