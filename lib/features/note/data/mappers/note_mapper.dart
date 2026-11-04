import 'package:taskee/features/note/data/model/note_hive_model.dart';
import 'package:taskee/features/note/domain/entities/note.dart';

extension NoteHiveModelToDomain on NoteHiveModel {
  Note toDomain() {
    final legacyTitle = note.trim().split('\n').first.trim();
    final displayTitle = title == 'Untitled' && legacyTitle.isNotEmpty
        ? (legacyTitle.length > 42 ? '${legacyTitle.substring(0, 42)}…' : legacyTitle)
        : title;
    return Note(
      id: id,
      title: displayTitle,
      note: note,
      createdAt: createdAt,
      parentId: parentId,
      isFolder: isFolder,
      isFavorite: isFavorite,
    );
  }
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
