import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp_example_app/data.dart';
import 'package:flutter_mcp_example_app/logic.dart';
import 'package:flutter_mcp_example_app/ui.dart';

class McpServerPage extends StatefulWidget {
  const McpServerPage({super.key});

  @override
  State<McpServerPage> createState() => _McpServerPageState();
}

class _McpServerPageState extends State<McpServerPage> {
  late final StreamSubscription<void> _darkModeToggleSubscription;

  @override
  void initState() {
    super.initState();
    _darkModeToggleSubscription = context
        .read<McpServerRepository>()
        .darkModeToggleRequests
        .listen((_) => _onDarkModeToggleRequested());
  }

  /// Opens the settings page (unless already open) and toggles dark mode,
  /// with a short delay so the switch visibly flips.
  Future<void> _onDarkModeToggleRequested() async {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      _openSettings();
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
    if (!mounted) return;
    context.read<ThemeCubit>().toggleDarkMode();
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  @override
  void dispose() {
    _darkModeToggleSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter MCP App'),
        actions: <Widget>[
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Impostazioni',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<McpServerBloc, McpServerState>(
          builder: (context, state) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                ServerStatusCard(state: state),
                const SizedBox(height: 16),
                Expanded(child: LogsConsole(logs: state.logs)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: state.logs.isEmpty
                        ? null
                        : () => context.read<McpServerBloc>().add(
                            const ClearLogsRequested(),
                          ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Pulisci log'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
