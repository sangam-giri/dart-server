import 'package:dart_server/features/item/data/item_model.dart';
import 'package:dart_server/features/item/data/repository/item_repository.dart';

class ItemService {
  final ItemRepository _repository;

  ItemService(this._repository);

  Future<List<Item>> getAllItems({String? name}) async {
    final query = name != null ? {'name': name} : null;
    return await _repository.findAll(query: query);
  }

  Future<Map<String, dynamic>?> getItem(String id) async {
    final item = await _repository.findOne(id);
    return item?.toJson();
  }

  Future<Map<String, dynamic>> createItem(Item item) async {
    final createdItem = await _repository.create(item);
    return createdItem.toJson();
  }

  Future<Item?> updateItem(String id, Item item) async {
    return await _repository.update(id, item);
  }

  Future<bool> deleteItem(String id) async {
    return await _repository.delete(id);
  }
}
