import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskee/app/theme/app_colors.dart';
import 'package:taskee/features/note/domain/entities/note.dart';
import 'package:taskee/features/note/presentation/bloc/note_bloc.dart';
import 'package:taskee/features/note/presentation/bloc/note_event.dart';
import 'package:taskee/features/note/presentation/bloc/note_state.dart';
import 'package:taskee/features/note/presentation/pages/note_editor_screen.dart';

class NoteWidget extends StatefulWidget {
  const NoteWidget({super.key});
  @override
  NoteWidgetState createState() => NoteWidgetState();
}

class NoteWidgetState extends State<NoteWidget> {
  final List<Note> _folderPath = [];
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  int? get _parentId => _folderPath.isEmpty ? null : _folderPath.last.id;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> showCreateMenu(BuildContext context) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.note_add_outlined, color: AppColors.accent),
            title: const Text('New page'),
            subtitle: const Text('Create a note or a nested page'),
            onTap: () => Navigator.pop(sheetContext, 'page'),
          ),
          ListTile(
            leading: const Icon(Icons.create_new_folder_outlined, color: AppColors.accent),
            title: const Text('New folder'),
            subtitle: const Text('Group related pages together'),
            onTap: () => Navigator.pop(sheetContext, 'folder'),
          ),
        ]),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'folder') {
      await _createFolder();
    } else {
      await Navigator.push(context, MaterialPageRoute(
        builder: (_) => NoteEditorScreen(parentId: _parentId),
      ));
    }
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create folder'),
        content: TextField(controller: controller, autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty || !mounted) return;
    final now = DateTime.now();
    context.read<NoteBloc>().add(NoteItemAddedEvent(Note(
      id: now.microsecondsSinceEpoch, title: title, note: '',
      createdAt: now, parentId: _parentId, isFolder: true,
    )));
  }

  Future<void> _rename(Note item) async {
    final controller = TextEditingController(text: item.title);
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.isFolder ? 'Rename folder' : 'Rename page'),
        content: TextField(controller: controller, autofocus: true,
          decoration: const InputDecoration(hintText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty || !mounted) return;
    context.read<NoteBloc>().add(NoteItemUpdatedEvent(Note(
      id: item.id, title: title, note: item.note, createdAt: item.createdAt,
      parentId: item.parentId, isFolder: item.isFolder, isFavorite: item.isFavorite,
    )));
  }

  void _toggleFavorite(Note item) {
    context.read<NoteBloc>().add(NoteItemUpdatedEvent(Note(
      id: item.id, title: item.title, note: item.note, createdAt: item.createdAt,
      parentId: item.parentId, isFolder: item.isFolder, isFavorite: !item.isFavorite,
    )));
  }

  Future<void> _delete(Note item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item.isFolder ? 'Delete folder?' : 'Delete page?'),
        content: const Text('This will also delete pages nested inside this item. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && mounted) context.read<NoteBloc>().add(NoteItemDeletedEvent(item.id));
  }

  void _openItem(Note item) {
    if (item.isFolder) {
      setState(() {
        _folderPath.add(item);
        _searchController.clear();
        _query = '';
      });
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditorScreen(note: item)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state is NoteLoadingState) return const Center(child: CircularProgressIndicator());
        if (state is NoteErrorState) return const Center(child: Text('Could not load your pages'));
        if (state is! NoteLoadedState) return const SizedBox.shrink();

        final allItems = state.noteModel.noteList;
        final List<Note> items = _query.isEmpty
            ? allItems.where((item) => item.parentId == _parentId).toList()
            : allItems.where((item) => !item.isFolder && item.title.toLowerCase().contains(_query.toLowerCase())).toList();
        items.sort((a, b) {
          if (a.isFolder != b.isFolder) return a.isFolder ? -1 : 1;
          if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
            child: Row(children: [
              if (_folderPath.isNotEmpty)
                IconButton(onPressed: () => setState(() => _folderPath.removeLast()), icon: const Icon(Icons.arrow_back)),
              Expanded(child: Text(
                _query.isNotEmpty ? 'Search results' : _folderPath.isEmpty ? 'My notes' : _folderPath.last.title,
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              )),
              if (_folderPath.isNotEmpty)
                IconButton(tooltip: 'Back to root', onPressed: () => setState(() => _folderPath.clear()), icon: const Icon(Icons.home_outlined)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                hintText: 'Search pages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty ? null : IconButton(
                  onPressed: () { _searchController.clear(); setState(() => _query = ''); },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
          if (_folderPath.isNotEmpty && _query.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 20, 0),
              child: Wrap(spacing: 5, children: [
                const Text('Home', style: TextStyle(color: AppColors.textMuted)),
                for (final folder in _folderPath) ...[
                  const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
                  Text(folder.title, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ]),
            ),
          const SizedBox(height: 14),
          Expanded(
            child: items.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.auto_stories_outlined, size: 54, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    Text(_query.isEmpty ? 'Nothing here yet' : 'No matching pages',
                      style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 5),
                    const Text('Tap + to create a page or folder',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(color: AppColors.kBorderColor, height: 1, indent: 54),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: Icon(item.isFolder ? Icons.folder_rounded : Icons.article_outlined,
                          color: item.isFolder ? AppColors.accent : AppColors.textSecondary),
                        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(item.isFolder ? 'Folder' : 'Page • ${_dateLabel(item.createdAt)}',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'rename') _rename(item);
                            if (value == 'favorite') _toggleFavorite(item);
                            if (value == 'delete') _delete(item);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'rename', child: Text('Rename')),
                            if (!item.isFolder) PopupMenuItem(value: 'favorite',
                              child: Text(item.isFavorite ? 'Remove favourite' : 'Add to favourites')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                        onTap: () => _openItem(item),
                      );
                    },
                  ),
          ),
        ]);
      },
    );
  }

  String _dateLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) return 'Today';
    return '${date.day}/${date.month}/${date.year}';
  }
}
