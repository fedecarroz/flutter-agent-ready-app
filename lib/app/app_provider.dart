import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp_example_app/data.dart';
import 'package:flutter_mcp_example_app/logic.dart';

class AppProvider extends StatefulWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  State<AppProvider> createState() => _AppProviderState();
}

class _AppProviderState extends State<AppProvider> {
  late final ThemeCubit _themeCubit;
  late final McpServerRepository _mcpServerRepository;

  @override
  void initState() {
    super.initState();
    _themeCubit = ThemeCubit();
    _mcpServerRepository = McpServerRepository(themeCubit: _themeCubit);
  }

  @override
  void dispose() {
    _mcpServerRepository.dispose();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider>[
        RepositoryProvider<McpServerRepository>.value(
          value: _mcpServerRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<McpServerBloc>(
            create: (context) =>
                McpServerBloc(context.read<McpServerRepository>()),
            lazy: false,
          ),
          BlocProvider<ThemeCubit>.value(
            value: _themeCubit,
          ),
        ],
        child: widget.child,
      ),
    );
  }
}
