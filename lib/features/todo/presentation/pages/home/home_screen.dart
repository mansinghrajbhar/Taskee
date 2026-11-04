import 'package:flutter/material.dart';
import 'package:taskee/features/note/presentation/pages/addNote/widget/note_widget.dart';
import 'package:taskee/features/widget/app_gradient.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<NoteWidgetState> _notesKey = GlobalKey<NoteWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradient(
        child: SafeArea(
          child: NoteWidget(key: _notesKey),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _notesKey.currentState?.showCreateMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
