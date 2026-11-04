class Note {
  final int id;
  final String title;
  final String note;
  final DateTime createdAt;
  final int? parentId;
  final bool isFolder;
  final bool isFavorite;

  const Note({
    required this.id,
    required this.note,
    required this.createdAt,
    this.title = 'Untitled',
    this.parentId,
    this.isFolder = false,
    this.isFavorite = false,
  });
}
