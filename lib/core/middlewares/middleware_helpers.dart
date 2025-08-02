import 'package:shelf/shelf.dart';

/// Wraps a handler with a list of middlewares.
Handler withMiddlewares(List<Middleware> middlewares, Handler handler) {
  var pipeline = Pipeline();
  for (final middleware in middlewares) {
    pipeline = pipeline.addMiddleware(middleware);
  }
  return pipeline.addHandler(handler);
}
