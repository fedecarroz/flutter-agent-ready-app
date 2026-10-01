import 'dart:async';
import 'dart:convert';

import 'package:flutter_mcp/flutter_mcp.dart';
import 'package:flutter_mcp_example_app/data.dart';

/// MCP-over-StreamableHTTP server exposing the native `get_location` tool.
class McpServerService {
  McpServerService(this._locationService);

  final LocationService _locationService;
  final _logs = StreamController<String>.broadcast();
  final _darkModeToggleRequests = StreamController<void>.broadcast();
  String? _serverId;
  bool _initialized = false;

  Stream<String> get logs => _logs.stream;

  /// Emits when an MCP client calls `toggle_dark_mode`.
  Stream<void> get darkModeToggleRequests => _darkModeToggleRequests.stream;
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
      name: 'flutter-location-mcp',
      version: '1.0.0',
      capabilities: ServerCapabilities(tools: ToolsCapability()),
      config: MCPServerConfig(
        name: 'flutter-location-mcp',
        version: '1.0.0',
        // SSE transport left behind deliberately: mcp_server 2.2.3's
        // SseServerTransport.close() iterates its live session map and calls
        // close() on responses with a pending flush, so stopping throws an
        // uncatchable async error and never closes the HttpServer (port leaks).
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
        name: 'toggle_dark_mode',
        description: 'Apre la pagina impostazioni dell\'app e attiva/disattiva la dark mode.',
        inputSchema: const {'type': 'object', 'properties': {}},
        handler: _handleToggleDarkMode,
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

  Future<CallToolResult> _handleToggleDarkMode(
    Map<String, dynamic> arguments,
  ) async {
    _logs.add('Tool ← toggle_dark_mode');
    _darkModeToggleRequests.add(null);
    _logs.add('Tool → dark mode commutata');
    return CallToolResult(content: [TextContent(text: 'Dark mode commutata')]);
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
    await _darkModeToggleRequests.close();
  }
}
