import 'dart:io';
import 'package:shelf/shelf_io.dart' as io;
import 'core/app.dart';

void main(List<String> args) async {
  final app = App();
  await app.initialize();

  // Clean up on process exit
  ProcessSignal.sigint.watch().listen((_) async {
    await app.close();
    exit(0);
  });

  final server = await io.serve(app.handler, '0.0.0.0', 8080);
  print('Server running on http://${server.address.host}:${server.port}');
}
