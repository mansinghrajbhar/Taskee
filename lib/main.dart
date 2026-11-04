import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskee/app/routing/go_router.dart';
import 'package:taskee/app/theme/app_theme.dart';
import 'package:taskee/di/dependency_injection.dart';
import 'package:taskee/features/note/data/datasource/hive_note_local_datasource.dart';
import 'package:taskee/features/note/presentation/bloc/note_bloc.dart';
import 'package:taskee/features/note/presentation/bloc/note_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final noteDatasource = HiveNoteLocalDatasource();
  await noteDatasource.initialize();
  await configureDependencies(hiveNoteLocalDatasource: noteDatasource);

  runApp(const TaskeeNotesApp());
}

class TaskeeNotesApp extends StatelessWidget {
  const TaskeeNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NoteBloc>()..add(const NoteStartedEvent()),
      child: MaterialApp.router(
        title: 'Taskee',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: goRouter,
      ),
    );
  }
}
