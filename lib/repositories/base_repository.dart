import '../models/base_model.dart';

abstract class BaseRepository<T extends BaseModel> {
  final String collectionName;

  BaseRepository(this.collectionName);

  Future<List<T>> findAll({Map<String, dynamic>? query});
  Future<T?> findOne(String id);
  Future<T> create(T item);
  Future<T?> update(String id, T item);
  Future<bool> delete(String id);
}
