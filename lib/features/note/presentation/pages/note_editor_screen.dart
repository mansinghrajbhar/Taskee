import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskee/app/theme/app_colors.dart';
import 'package:taskee/features/note/domain/entities/note.dart';
import 'package:taskee/features/note/presentation/bloc/note_bloc.dart';
import 'package:taskee/features/note/presentation/bloc/note_event.dart';
import 'package:taskee/features/note/presentation/bloc/note_state.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final int? parentId;
  const NoteEditorScreen({super.key, this.note, this.parentId});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final TextEditingController _titleController;
  final List<Map<String, dynamic>> _blocks = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _loadBlocks();
  }

  void _loadBlocks() {
    final raw = widget.note?.note ?? '';
    if (raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is Map) _blocks.add(Map<String, dynamic>.from(item));
          }
        } else {
          _blocks.add({'type': 'paragraph', 'text': raw});
        }
      } catch (_) {
        _blocks.add({'type': 'paragraph', 'text': raw});
      }
    }
    if (_blocks.isEmpty) _blocks.add({'type': 'paragraph', 'text': ''});
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final note = Note(
      id: widget.note?.id ?? now.microsecondsSinceEpoch,
      title: _titleController.text.trim().isEmpty ? 'Untitled' : _titleController.text.trim(),
      note: jsonEncode(_blocks),
      createdAt: widget.note?.createdAt ?? now,
      parentId: widget.note?.parentId ?? widget.parentId,
      isFavorite: widget.note?.isFavorite ?? false,
    );
    context.read<NoteBloc>().add(widget.note == null
        ? NoteItemAddedEvent(note)
        : NoteItemUpdatedEvent(note));
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved on this device')),
      );
    }
  }

  void _addBlock(String type) {
    setState(() {
      _blocks.add({
        'type': type,
        'text': '',
        if (type == 'checkbox') 'checked': false,
        if (type == 'toggle') 'expanded': true,
        if (type == 'toggle') 'children': [{'text': ''}],
      });
    });
  }

  Widget _blockEditor(int index) {
    final block = _blocks[index];
    final type = block['type'] as String? ?? 'paragraph';
    final textStyle = switch (type) {
      'heading' => const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      'subheading' => const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      _ => const TextStyle(fontSize: 16, height: 1.5),
    };

    Widget field({String? hint, TextStyle? style}) => TextFormField(
      key: ValueKey('block-${index}-${type}'),
      initialValue: block['text'] as String? ?? '',
      onChanged: (value) => block['text'] = value,
      style: style ?? textStyle,
      minLines: 1,
      maxLines: null,
      decoration: InputDecoration(
        hintText: hint ?? 'Write something...',
        filled: false,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 7),
      ),
    );

    if (type == 'toggle') {
      final expanded = block['expanded'] as bool? ?? true;
      final children = (block['children'] as List?) ?? [];
      if (children.isEmpty) {
        children.add({'text': ''});
        block['children'] = children;
      }
      final child = Map<String, dynamic>.from(children.first as Map);
      children[0] = child;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => block['expanded'] = !expanded),
                  icon: Icon(expanded ? Icons.keyboard_arrow_down : Icons.chevron_right),
                ),
                Expanded(child: field(hint: 'Toggle heading')),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _blocks.removeAt(index)),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.only(left: 46, right: 12),
                child: TextFormField(
                  key: ValueKey('toggle-child-${index}'),
                  initialValue: child['text'] as String? ?? '',
                  onChanged: (value) => child['text'] = value,
                  minLines: 1,
                  maxLines: null,
                  style: const TextStyle(height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'Write hidden content...',
                    filled: false,
                    border: InputBorder.none,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (type == 'bullet')
            const Padding(
              padding: EdgeInsets.only(top: 14, right: 10),
              child: Icon(Icons.circle, size: 7, color: AppColors.accent),
            ),
          if (type == 'numbered')
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Text('${index + 1}.', style: const TextStyle(color: AppColors.accent)),
            ),
          if (type == 'checkbox')
            Checkbox(
              value: block['checked'] as bool? ?? false,
              onChanged: (value) => setState(() => block['checked'] = value ?? false),
              activeColor: AppColors.accent,
            ),
          Expanded(child: field(
            hint: type == 'heading' ? 'Heading' : type == 'subheading' ? 'Subheading' : 'Write something...',
          )),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() => _blocks.removeAt(index)),
            icon: const Icon(Icons.close, size: 18, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Future<void> _createSubpage() async {
    final title = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New subpage'),
        content: TextField(
          controller: title,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Page title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, title.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (result == null || result.isEmpty || !mounted) return;
    final now = DateTime.now();
    final subpage = Note(
      id: now.microsecondsSinceEpoch,
      title: result,
      note: '',
      createdAt: now,
      parentId: widget.note?.id,
    );
    context.read<NoteBloc>().add(NoteItemAddedEvent(subpage));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Subpage "$result" created')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.note == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New page' : 'Edit page'),
        actions: [
          if (!isNew)
            IconButton(
              tooltip: 'Create subpage',
              onPressed: _createSubpage,
              icon: const Icon(Icons.note_add_outlined),
            ),
          IconButton(
            tooltip: 'Save',
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      hintText: 'Untitled',
                      filled: false,
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_blocks.length, _blockEditor),
                  if (widget.note != null) _subpagesSection(),
                  const SizedBox(height: 90),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.kBorderColor)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _tool('Text', Icons.notes, 'paragraph'),
                      _tool('Heading', Icons.title, 'heading'),
                      _tool('Subhead', Icons.format_size, 'subheading'),
                      _tool('Bullet', Icons.format_list_bulleted, 'bullet'),
                      _tool('Number', Icons.format_list_numbered, 'numbered'),
                      _tool('Checklist', Icons.check_box_outlined, 'checkbox'),
                      _tool('Toggle', Icons.keyboard_arrow_down, 'toggle'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subpagesSection() {
    return BlocBuilder<NoteBloc, NoteState>(
      builder: (context, state) {
        if (state is! NoteLoadedState || widget.note == null) {
          return const SizedBox.shrink();
        }
        final children = state.noteModel.noteList
            .where((item) => item.parentId == widget.note!.id && !item.isFolder)
            .toList();
        return Padding(
          padding: const EdgeInsets.only(top: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Subpages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                  TextButton.icon(
                    onPressed: _createSubpage,
                    icon: const Icon(Icons.add, size: 17),
                    label: const Text('Add'),
                  ),
                ],
              ),
              if (children.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('No subpages yet', style: TextStyle(color: AppColors.textMuted)),
                )
              else
                ...children.map((child) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.article_outlined, color: AppColors.accent),
                  title: Text(child.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NoteEditorScreen(note: child)),
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _tool(String label, IconData icon, String type) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: ActionChip(
      avatar: Icon(icon, size: 17),
      label: Text(label),
      onPressed: () => _addBlock(type),
    ),
  );
}
