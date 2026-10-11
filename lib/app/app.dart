import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp_example_app/app.dart';
import 'package:flutter_mcp_example_app/logic.dart';
import 'package:flutter_mcp_example_app/ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter MCP App',
          theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.teal,
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: themeMode,
          home: const McpServerPage(),
        ),
      ),
    );
  }
}
