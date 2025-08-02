import 'dart:io';
import 'package:dart_server/core/middlewares/logging_middleware.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'app.dart';

void main(List<String> args) async {
  final app = App();

  stdout.writeln('$cyan[server] Initializing app...$reset');
  await app.initialize();
  stdout.writeln('$green[server] Initialization complete.$reset');

  // Handle Ctrl+C or termination
  ProcessSignal.sigint.watch().listen((_) async {
    stdout.writeln('$yellow[server] Received SIGINT. Shutting down...$reset');
    await app.close();
    stdout.writeln('$green[server] Cleanup complete. Exiting.$reset');
    exit(0);
  });

  try {
    final server = await io.serve(app.handler, '0.0.0.0', 8080);
    final address = server.address.address;
    final port = server.port;
    stdout.writeln(
      '$green[server] 🚀 Server running at: $cyan http://$address:$port $reset',
    );
  } catch (e) {
    stderr.writeln('$red[server] Failed to start server: $e$reset');
    exit(1);
  }
}
