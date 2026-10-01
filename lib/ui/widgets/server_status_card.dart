import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp_example_app/logic.dart';

class ServerStatusCard extends StatelessWidget {
  final McpServerState state;

  const ServerStatusCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 14,
                  color: state.isRunning ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  state.isRunning ? 'Server attivo' : 'Server inattivo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: state.isStartInProgress
                      ? null
                      : () => context.read<McpServerBloc>().add(
                          state.isRunning
                              ? const StopServerRequested()
                              : StartServerRequested(state.port),
                        ),
                  icon: Icon(state.isRunning ? Icons.stop : Icons.play_arrow),
                  label: Text(state.isRunning ? 'Arresta' : 'Avvia'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SelectableText(
              'http://localhost:${state.port}/mcp',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}
