import 'package:dart_server/routes/base_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import '../config/database.dart';
import '../routes/item_router.dart';
import '../services/item_service.dart';
import '../repositories/item_repository.dart';
import 'middlewares/cors_middleware.dart';
import 'middlewares/logging_middleware.dart';

class App {
  final Router _router = Router();
  final List<BaseRouter> _routers = [];

  Future<void> initialize() async {
    // Load environment variables
    final env = DotEnv(includePlatformEnvironment: true)..load();

    // Initialize database
    await DatabaseConfig.initialize(
      env['MONGODB_URI'] ?? 'mongodb://localhost:27017/dart_crud',
    );
    DatabaseConfig.registerCollection('items');

    // Initialize services and routers
    final itemService = ItemService(ItemRepository());
    _routers.add(ItemRouter(itemService));

    // Mount all routers
    for (final router in _routers) {
      _router.mount('/items', router.router.call);
    }
  }

  Handler get handler {
    final pipeline = Pipeline()
        .addMiddleware(loggingMiddleware())
        .addMiddleware(corsMiddleware())
        // Add other middlewares as needed
        // .addMiddleware(authMiddleware())
        // .addMiddleware(requestValidationMiddleware({'name': 'required'}))
        .addHandler(_router.call);

    return pipeline;
  }

  Future<void> close() async {
    await DatabaseConfig.close();
  }
}
