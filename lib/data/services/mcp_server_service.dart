import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mcp/flutter_mcp.dart';
import 'package:flutter_mcp_example_app/data.dart';
import 'package:flutter_mcp_example_app/logic.dart';

/// MCP-over-StreamableHTTP server exposing native tools.
class McpServerService {
  McpServerService(this._locationService, {ThemeCubit? themeCubit})
    : _themeCubit = themeCubit ?? ThemeCubit();

  final LocationService _locationService;
  final ThemeCubit _themeCubit;
  final _logs = StreamController<String>.broadcast();
  final _themeRequests = StreamController<ThemeMode>.broadcast();
  String? _serverId;
  bool _initialized = false;

  Stream<String> get logs => _logs.stream;

  /// Emits when an MCP client requests a theme change.
  Stream<ThemeMode> get themeRequests => _themeRequests.stream;

  ThemeCubit get themeCubit => _themeCubit;

  bool get isRunning => _serverId != null;

  Future<void> start(int port) async {
    if (isRunning) return;
    if (!_initialized) {
      await FlutterMCP.instance.init(
        MCPConfig(
          appName: 'Flutter MPC App',
          appVersion: '1.0.0',
          autoStart: false,
        ),
      );
      _initialized = true;
    }
    final serverId = await FlutterMCP.instance.createServer(
      name: 'flutter-custom-mcp',
      version: '1.0.0',
      capabilities: ServerCapabilities(tools: ToolsCapability()),
      config: MCPServerConfig(
        name: 'flutter-custom-mcp',
        version: '1.0.0',
        transportType: 'streamablehttp',
        streamableHttpPort: port,
        host: '0.0.0.0',
        endpoint: '/mcp',
      ),
    );
    final server = FlutterMCP.instance.getServer(serverId)!;
    server
      ..addTool(
        name: 'get_location',
        description: 'Restituisce la posizione GPS corrente del dispositivo.',
        inputSchema: const {
          'type': 'object',
          'properties': {
            'highAccuracy': {
              'type': 'boolean',
              'description': 'Usa GPS ad alta precisione.',
            },
          },
        },
        handler: _handleGetLocation,
      )
      ..addTool(
        name: 'set_theme',
        description: 'Imposta il tema dell\'app: chiaro o scuro',
        inputSchema: const {
          'type': 'object',
          'properties': {
            'mode': {
              'type': 'string',
              'enum': ['light', 'dark'],
            },
          },
          'required': ['mode'],
        },
        handler: handleSetTheme,
      );
    FlutterMCP.instance.connectServer(serverId);
    _serverId = serverId;
    _logs.add('Server MCP avviato su http://localhost:$port/mcp');
  }

  Future<CallToolResult> _handleGetLocation(
    Map<String, dynamic> arguments,
  ) async {
    _logs.add('Tool ← get_location ${jsonEncode(arguments)}');
    try {
      final location = await _locationService.getLocation(
        highAccuracy: arguments['highAccuracy'] == true,
      );
      final encoded = jsonEncode(location);
      _logs.add('Tool → $encoded');
      return CallToolResult(content: [TextContent(text: encoded)]);
    } catch (error) {
      _logs.add('Tool → errore: $error');
      return CallToolResult(
        content: [TextContent(text: error.toString())],
        isError: true,
      );
    }
  }

  Future<CallToolResult> handleSetTheme(Map<String, dynamic> arguments) async {
    _logs.add('Tool ← set_theme ${jsonEncode(arguments)}');
    final mode = arguments['mode'];
    if (mode is! String || (mode != 'light' && mode != 'dark')) {
      const errorMessage =
          'Parametro "mode" non valido o mancante. Valori ammessi: "light", "dark".';
      _logs.add('Tool → errore: $errorMessage');
      return CallToolResult(
        content: [TextContent(text: errorMessage)],
        isError: true,
      );
    }

    final themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _themeCubit.setTheme(themeMode);
    _themeRequests.add(themeMode);
    final statusText = 'Tema attivo: $mode';
    _logs.add('Tool → $statusText');
    return CallToolResult(content: [TextContent(text: statusText)]);
  }

  Future<void> stop() async {
    final serverId = _serverId;
    if (serverId == null) return;
    await FlutterMCP.instance.serverManager.closeServer(serverId);
    _serverId = null;
    _logs.add('Server MCP arrestato');
  }

  Future<void> dispose() async {
    await stop();
    await _logs.close();
    await _themeRequests.close();
  }
}
