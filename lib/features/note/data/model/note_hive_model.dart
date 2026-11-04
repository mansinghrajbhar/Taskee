import 'package:hive/hive.dart';

part 'note_hive_model.g.dart';

@HiveType(typeId: 2)
class NoteHiveModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String note;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final int? parentId;

  @HiveField(5)
  final bool isFolder;

  @HiveField(6)
  final bool isFavorite;

  const NoteHiveModel({
    required this.id,
    required this.note,
    required this.createdAt,
    this.title = 'Untitled',
    this.parentId,
    this.isFolder = false,
    this.isFavorite = false,
  });
}
