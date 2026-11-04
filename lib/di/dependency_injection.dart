import 'package:get_it/get_it.dart';
import 'package:taskee/features/note/data/datasource/hive_note_local_datasource.dart';
import 'package:taskee/features/note/data/datasource/note_local_datasource.dart';
import 'package:taskee/features/note/data/repository/note_repository_impl.dart';
import 'package:taskee/features/note/domain/repository/note_repository.dart';
import 'package:taskee/features/note/domain/usecase/add_note.dart';
import 'package:taskee/features/note/domain/usecase/delete_note.dart';
import 'package:taskee/features/note/domain/usecase/get_all_notes.dart';
import 'package:taskee/features/note/domain/usecase/update_note.dart';
import 'package:taskee/features/note/presentation/bloc/note_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({
  required HiveNoteLocalDatasource hiveNoteLocalDatasource,
}) async {
  if (getIt.isRegistered<NoteLocalDatasource>()) return;

  getIt.registerLazySingleton<NoteLocalDatasource>(() => hiveNoteLocalDatasource);
  getIt.registerLazySingleton<NoteRepository>(() => NoteRepositoryImpl(getIt()));
  getIt.registerLazySingleton<GetAllNotes>(() => GetAllNotes(getIt()));
  getIt.registerLazySingleton<AddNote>(() => AddNote(getIt()));
  getIt.registerLazySingleton<UpdateNote>(() => UpdateNote(getIt()));
  getIt.registerLazySingleton<DeleteNote>(() => DeleteNote(getIt()));
  getIt.registerFactory<NoteBloc>(() => NoteBloc(
    getAllNotes: getIt(),
    addNote: getIt(),
    updateNote: getIt(),
    deleteNote: getIt(),
  ));
}
