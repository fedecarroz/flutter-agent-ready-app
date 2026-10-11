part of 'mcp_server_bloc.dart';

enum McpServerStatus {
  initial,
  startInProgress,
  running,
  stopped,
  startFailure,
}

class McpServerState extends Equatable {
  final McpServerStatus status;
  final int port;
  final List<String> logs;

  const McpServerState({
    this.status = McpServerStatus.initial,
    this.port = 8080,
    this.logs = const [],
  });

  McpServerState copyWith({
    McpServerStatus? status,
    int? port,
    List<String>? logs,
  }) {
    return McpServerState(
      status: status ?? this.status,
      port: port ?? this.port,
      logs: logs ?? this.logs,
    );
  }

  bool get isRunning => status == McpServerStatus.running;
  bool get isStartInProgress => status == McpServerStatus.startInProgress;
  bool get isStartFailure => status == McpServerStatus.startFailure;

  @override
  List<Object?> get props => [status, port, logs];
}
