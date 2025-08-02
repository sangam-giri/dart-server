import 'package:dart_server/core/middlewares/logging_middleware.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DatabaseConfig {
  static late Db _db;
  static late Map<String, DbCollection> _collections;

  static Future<void> initialize(String uri) async {
    _db = await Db.create(uri);
    await _db.open();
    _collections = {};
    serverLog('Connected to MongoDB');
  }

  static void registerCollection(String name) {
    _collections[name] = _db.collection(name);
  }

  static DbCollection collection(String name) {
    if (!_collections.containsKey(name)) {
      throw Exception('Collection $name not registered');
    }
    return _collections[name]!;
  }

  static Future<void> close() async {
    await _db.close();
  }
}
