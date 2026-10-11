import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_mcp_example_app/data.dart';

part 'mcp_server_event.dart';
part 'mcp_server_state.dart';

class McpServerBloc extends Bloc<McpServerEvent, McpServerState> {
  final McpServerRepository _mcpServerRepo;

  McpServerBloc(this._mcpServerRepo) : super(const McpServerState()) {
    on<StartServerRequested>(_onStartServerRequested);
    on<StopServerRequested>(_onStopServerRequested);
    on<LogReceived>(_onLogReceived);
    on<ClearLogsRequested>(_onClearLogsRequested);
    _logsSubscription = _mcpServerRepo.logs.listen(
      (log) => add(LogReceived(log)),
    );
  }

  late final StreamSubscription<String> _logsSubscription;

  Future<void> _onStartServerRequested(
    StartServerRequested event,
    Emitter<McpServerState> emit,
  ) async {
    emit(state.copyWith(status: McpServerStatus.startInProgress));
    try {
      await _mcpServerRepo.start(event.port);
      emit(state.copyWith(status: McpServerStatus.running, port: event.port));
    } catch (error) {
      emit(
        state.copyWith(
          status: McpServerStatus.startFailure,
          logs: [...state.logs, 'Errore server: $error'],
        ),
      );
    }
  }

  Future<void> _onStopServerRequested(
    StopServerRequested event,
    Emitter<McpServerState> emit,
  ) async {
    await _mcpServerRepo.stop();
    emit(state.copyWith(status: McpServerStatus.stopped));
  }

  void _onLogReceived(LogReceived event, Emitter<McpServerState> emit) {
    emit(state.copyWith(logs: [...state.logs, event.log]));
  }

  void _onClearLogsRequested(
    ClearLogsRequested event,
    Emitter<McpServerState> emit,
  ) {
    emit(state.copyWith(logs: const []));
  }

  @override
  Future<void> close() async {
    await _logsSubscription.cancel();
    return super.close();
  }
}
