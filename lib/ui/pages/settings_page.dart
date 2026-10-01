import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp_example_app/logic.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impostazioni')),
      body: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDarkMode) => SwitchListTile(
          title: const Text('Dark mode'),
          secondary: const Icon(Icons.dark_mode_outlined),
          value: isDarkMode,
          onChanged: (_) => context.read<ThemeCubit>().toggleDarkMode(),
        ),
      ),
    );
  }
}
