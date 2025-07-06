import 'dart:convert';

import 'package:dart_server/core/routes/base_router.dart';
import 'package:dart_server/core/utils/response_utils.dart';
import 'package:dart_server/features/item/data/item_model.dart';
import 'package:dart_server/features/item/domain/services/item_service.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ItemRouter implements BaseRouter {
  final ItemService _service;

  ItemRouter(this._service);

  @override
  Router get router {
    final router = Router();

    router.get('/', (Request request) async {
      try {
        final name = request.url.queryParameters['name'];
        final items = await _service.getAllItems(name: name);
        return ResponseUtils.success(items);
      } catch (e) {
        return ResponseUtils.serverError(e.toString());
      }
    });

    router.get('/<id>', (Request request, String id) async {
      try {
        final item = await _service.getItem(id);
        return item != null
            ? ResponseUtils.success(item)
            : ResponseUtils.notFound();
      } catch (e) {
        return ResponseUtils.serverError(e.toString());
      }
    });

    router.post('/', (Request request) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body);
        final item =
            Item()
              ..name = json['name']
              ..description = json['description'];
        final createdItem = await _service.createItem(item);
        return ResponseUtils.success(createdItem, statusCode: 201);
      } catch (e) {
        return ResponseUtils.error(e.toString());
      }
    });

    router.put('/<id>', (Request request, String id) async {
      try {
        final body = await request.readAsString();
        final json = jsonDecode(body);
        final item =
            Item()
              ..name = json['name']
              ..description = json['description'];
        final updatedItem = await _service.updateItem(id, item);
        return updatedItem != null
            ? ResponseUtils.success(updatedItem)
            : ResponseUtils.notFound();
      } catch (e) {
        return ResponseUtils.error(e.toString());
      }
    });

    router.delete('/<id>', (Request request, String id) async {
      try {
        final success = await _service.deleteItem(id);
        return success
            ? ResponseUtils.success('Item deleted')
            : ResponseUtils.notFound();
      } catch (e) {
        return ResponseUtils.error(e.toString());
      }
    });

    return router;
  }
}
