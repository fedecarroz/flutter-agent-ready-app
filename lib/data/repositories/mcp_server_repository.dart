import 'package:flutter_mcp_example_app/data.dart';

class McpServerRepository {
  final _mcpServerService = McpServerService(LocationService());

  McpServerRepository();

  /// Log lines produced by the MCP server and its tools.
  Stream<String> get logs => _mcpServerService.logs;

  /// Emits when an MCP client asks to toggle dark mode.
  Stream<void> get darkModeToggleRequests =>
      _mcpServerService.darkModeToggleRequests;

  bool get isRunning => _mcpServerService.isRunning;

  /// Start the MCP server on [port].
  Future<void> start(int port) => _mcpServerService.start(port);

  /// Stop the MCP server and release the port.
  Future<void> stop() => _mcpServerService.stop();

  Future<void> dispose() => _mcpServerService.dispose();
}
