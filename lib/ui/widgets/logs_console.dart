import 'package:flutter/material.dart';

class LogsConsole extends StatelessWidget {
  final List<String> logs;

  const LogsConsole({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.black,
      child: logs.isEmpty
          ? const Text(
              'In attesa di richieste MCP...',
              style: TextStyle(color: Colors.green, fontFamily: 'monospace'),
            )
          : ListView.builder(
              itemCount: logs.length,
              itemBuilder: (_, index) => Text(
                logs[index],
                style: const TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                ),
              ),
            ),
    );
  }
}
