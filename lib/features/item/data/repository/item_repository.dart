import 'package:dart_server/core/config/database.dart';
import 'package:dart_server/core/repositories/base_repository.dart';
import 'package:dart_server/features/item/data/item_model.dart';
import 'package:mongo_dart/mongo_dart.dart';


class ItemRepository extends BaseRepository<Item> {
  ItemRepository() : super('items');

  @override
  Future<List<Item>> findAll({Map<String, dynamic>? query}) async {
    final items =
        await DatabaseConfig.collection(
          collectionName,
        ).find(query ?? {}).toList();
    return items.map((item) => Item.fromMap(item)).toList();
  }

  @override
  Future<Item?> findOne(String id) async {
    try {
      final item = await DatabaseConfig.collection(
        collectionName,
      ).findOne(where.id(ObjectId.fromHexString(id)));
      return item != null ? Item.fromMap(item) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Item> create(Item item) async {
    item.createdAt = DateTime.now().toUtc();
    final result = await DatabaseConfig.collection(
      collectionName,
    ).insertOne(item.toJson())  ;
    item.id = result.id as ObjectId;
    return item;
  }

  @override
  Future<Item?> update(String id, Item item) async {
    item.updatedAt = DateTime.now().toUtc();
    final result = await DatabaseConfig.collection(
      collectionName,
    ).updateOne(where.id(ObjectId.fromHexString(id)), {'\$set': item.toJson()});
    return result.isSuccess ? await findOne(id) : null;
  }

  @override
  Future<bool> delete(String id) async {
    final result = await DatabaseConfig.collection(
      collectionName,
    ).deleteOne(where.id(ObjectId.fromHexString(id)));
    return result.isSuccess && result.nRemoved > 0;
  }
}
