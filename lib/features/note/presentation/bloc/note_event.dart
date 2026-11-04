import 'package:equatable/equatable.dart';
import 'package:taskee/features/note/domain/entities/note.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class NoteStartedEvent extends NoteEvent {
  const NoteStartedEvent();
}

class NoteItemAddedEvent extends NoteEvent {
  final Note note;
  const NoteItemAddedEvent(this.note);

  @override
  List<Object?> get props => [note.id, note.title, note.note, note.parentId];
}

class NoteItemUpdatedEvent extends NoteEvent {
  final Note note;
  const NoteItemUpdatedEvent(this.note);

  @override
  List<Object?> get props => [note.id, note.title, note.note, note.parentId, note.isFavorite];
}

class NoteItemDeletedEvent extends NoteEvent {
  final int id;
  const NoteItemDeletedEvent(this.id);

  @override
  List<Object?> get props => [id];
}
