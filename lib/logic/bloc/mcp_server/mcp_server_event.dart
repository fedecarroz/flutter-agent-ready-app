part of 'mcp_server_bloc.dart';

sealed class McpServerEvent extends Equatable {
  const McpServerEvent();

  @override
  List<Object?> get props => [];
}

class StartServerRequested extends McpServerEvent {
  final int port;

  const StartServerRequested(this.port);

  @override
  List<Object?> get props => [port];
}

class StopServerRequested extends McpServerEvent {
  const StopServerRequested();
}

class LogReceived extends McpServerEvent {
  final String log;

  const LogReceived(this.log);

  @override
  List<Object?> get props => [log];
}

class ClearLogsRequested extends McpServerEvent {
  const ClearLogsRequested();
}
