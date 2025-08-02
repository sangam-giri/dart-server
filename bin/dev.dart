import 'dart:async';
import 'dart:io';
import 'package:watcher/watcher.dart';
import 'package:dart_server/core/middlewares/logging_middleware.dart';

void main() async {
  Process? serverProcess;

  Future<void> startServer() async {
    // Kill existing process if running
    if (serverProcess != null) {
      stdout.writeln('$yellow[dev] Restarting server...$reset');
      serverProcess!.kill(ProcessSignal.sigterm);
    }

    try {
      serverProcess = await Process.start('dart', [
        'run',
        'bin/server.dart',
      ], mode: ProcessStartMode.inheritStdio);
      stdout.writeln('$green[dev] Server started successfully.$reset');
    } catch (e) {
      stderr.writeln('$red[dev] Failed to start server: $e$reset');
    }
  }

  // Initial server start
  await startServer();

  final directoriesToWatch = ['lib', 'bin'];

  stdout.writeln('$cyan[dev] Running in watch mode...$reset');

  for (final dir in directoriesToWatch) {
    final watcher = DirectoryWatcher(dir);
    watcher.events.listen((event) async {
      if (event.type != ChangeType.REMOVE) {
        stdout.writeln('$yellow[dev] Detected change: ${event.path}$reset');
        await startServer();
      }
    });
  }
}

log() => '[Debug]';
