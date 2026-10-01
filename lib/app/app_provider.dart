import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mcp_example_app/data.dart';
import 'package:flutter_mcp_example_app/logic.dart';

class AppProvider extends StatelessWidget {
  final Widget child;

  const AppProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: <RepositoryProvider>[
        RepositoryProvider<McpServerRepository>(
          create: (_) => McpServerRepository(),
          dispose: (repository) => repository.dispose(),
        ),
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<McpServerBloc>(
            create: (context) =>
                McpServerBloc(context.read<McpServerRepository>()),
            lazy: false,
          ),
          BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        ],
        child: child,
      ),
    );
  }
}
