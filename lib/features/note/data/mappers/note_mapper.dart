import 'package:taskee/features/note/data/model/note_hive_model.dart';
import 'package:taskee/features/note/domain/entities/note.dart';

extension NoteHiveModelToDomain on NoteHiveModel {
  Note toDomain() => Note(
    id: id,
    title: title,
    note: note,
    createdAt: createdAt,
    parentId: parentId,
    isFolder: isFolder,
    isFavorite: isFavorite,
  );
}

extension NoteDomainToHiveModel on Note {
  NoteHiveModel toHiveModel() => NoteHiveModel(
    id: id,
    title: title,
    note: note,
    createdAt: createdAt,
    parentId: parentId,
    isFolder: isFolder,
    isFavorite: isFavorite,
  );
}
