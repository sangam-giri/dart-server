import 'package:dart_server/core/middlewares/auth_middleware.dart';
import 'package:dart_server/core/routes/base_router.dart';
import 'package:dart_server/features/item/data/repository/item_repository.dart';
import 'package:dart_server/features/item/domain/services/item_service.dart';
import 'package:dart_server/features/item/presentation/routes/item_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import 'core/config/database.dart';
import 'core/middlewares/cors_middleware.dart';
import 'core/middlewares/logging_middleware.dart';

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
    DatabaseConfig.registerCollection('users');

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
        .addMiddleware(authMiddleware())
        // .addMiddleware(requestValidationMiddleware({'name': 'required'}))
        .addHandler(_router.call);

    return pipeline;
  }

  Future<void> close() async {
    await DatabaseConfig.close();
  }
}
