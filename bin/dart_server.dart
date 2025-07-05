import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// In-memory "database" for demonstration
final _items = <Map<String, dynamic>>[
  {'id': 1, 'name': 'Item 1', 'description': 'First item'},
  {'id': 2, 'name': 'Item 2', 'description': 'Second item'},
];

void main(List<String> args) async {
  final app = Router();

  // Create
  app.post('/items', (Request request) async {
    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final newId = _items.isEmpty ? 1 : _items.last['id'] + 1;
    final newItem = {'id': newId, ...data};
    _items.add(newItem);
    return Response.ok(
      jsonEncode(newItem),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Read all
  app.get('/items', (Request request) {
    return Response.ok(
      jsonEncode(_items),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Read single
  app.get('/items/<id>', (Request request, String id) {
    final itemId = int.tryParse(id);
    if (itemId == null) {
      return Response.badRequest(body: 'Invalid ID');
    }

    final item = _items.firstWhere(
      (item) => item['id'] == itemId,
      orElse: () => {},
    );

    return Response.ok(
      jsonEncode(item),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Update
  app.put('/items/<id>', (Request request, String id) async {
    final itemId = int.tryParse(id);
    if (itemId == null) {
      return Response.badRequest(body: 'Invalid ID');
    }

    final index = _items.indexWhere((item) => item['id'] == itemId);
    if (index == -1) {
      return Response.notFound('Item not found');
    }

    final body = await request.readAsString();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final updatedItem = {..._items[index], ...data, 'id': itemId};
    _items[index] = updatedItem;

    return Response.ok(
      jsonEncode(updatedItem),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // Delete
  app.delete('/items/<id>', (Request request, String id) {
    final itemId = int.tryParse(id);
    if (itemId == null) {
      return Response.badRequest(body: 'Invalid ID');
    }

    final index = _items.indexWhere((item) => item['id'] == itemId);
    if (index == -1) {
      return Response.notFound('Item not found');
    }

    _items.removeAt(index);
    return Response.ok('Item deleted');
  });

  // Start server
  final server = await io.serve(app.call, '0.0.0.0', 8080);

  print('Server running on http://${server.address.host}:${server.port}');
}
