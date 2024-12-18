import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gnotes/models/notes.dart';
import 'package:gnotes/util/db_helper.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen(
      {super.key, required this.noteColor, required this.helper});

  final Color noteColor;
  final DbHelper helper;

  @override
  State<NewNoteScreen> createState() => _NewNoteScreenState();
}

class _NewNoteScreenState extends State<NewNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  bool isInsetingNote = false;

  @override
  void initState() {
    super.initState();
  }

  //widget.notes.title,]
  bool isTitleNotEmpty() {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Note title can't be left empty."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      HapticFeedback.mediumImpact();
      return false;
    }
    return true;
  }

  void goBackAfterInsertingNote() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: isInsetingNote
              ? const CircularProgressIndicator.adaptive()
              : const Icon(
                  Icons.save,
                  color: Colors.black,
                ),
          onPressed: () async {
            setState(() {
              isInsetingNote = true;
            });
            if (isTitleNotEmpty()) {
              int? result = await widget.helper.insertANote(Notes(
                  title: titleController.text.trim(),
                  description: descController.text.trim(),
                  color: widget.noteColor.toString(),
                  id: null));

              log("result after insertion $result");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Note created!"),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );

              goBackAfterInsertingNote();
            }
            setState(() {
              isInsetingNote = false;
            });
          }),
      backgroundColor: widget.noteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
          child: AppBar(
            elevation: 4,
            backgroundColor: widget.noteColor,
            title: TextField(
              controller: titleController,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Enter title here",
                hintStyle: TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: descController,
                maxLines: 100,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Continue writing here..",
                  hintStyle: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
