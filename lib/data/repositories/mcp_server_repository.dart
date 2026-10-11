import 'package:flutter/material.dart';
import 'package:flutter_mcp_example_app/data.dart';
import 'package:flutter_mcp_example_app/logic.dart';

class McpServerRepository {
  final McpServerService _mcpServerService;

  McpServerRepository({
    ThemeCubit? themeCubit,
    LocationService? locationService,
    DateTime Function()? clock,
  }) : _mcpServerService = McpServerService(
          locationService ?? LocationService(),
          themeCubit: themeCubit,
          clock: clock,
        );

  /// Log lines produced by the MCP server and its tools.
  Stream<String> get logs => _mcpServerService.logs;

  /// Emits when an MCP client requests a theme change.
  Stream<ThemeMode> get themeRequests => _mcpServerService.themeRequests;

  ThemeCubit get themeCubit => _mcpServerService.themeCubit;

  bool get isRunning => _mcpServerService.isRunning;

  /// Start the MCP server on [port].
  Future<void> start(int port) => _mcpServerService.start(port);

  /// Stop the MCP server and release the port.
  Future<void> stop() => _mcpServerService.stop();

  Future<void> dispose() => _mcpServerService.dispose();
}
