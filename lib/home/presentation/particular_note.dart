import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gnotes/global/global.dart';
import 'package:gnotes/models/notes.dart';
import 'package:gnotes/util/db_helper.dart';

class ParticularNoteScreen extends StatefulWidget {
  const ParticularNoteScreen(
      {super.key,
      required this.notes,
      required this.noteColor,
      required this.helper});
  final Notes notes;
  final Color noteColor;
  final DbHelper helper;

  @override
  State<ParticularNoteScreen> createState() => _ParticularNoteScreenState();
}

class _ParticularNoteScreenState extends State<ParticularNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  bool readOnly = true;

  @override
  void initState() {
    titleController.text = widget.notes.title;
    descController.text = widget.notes.description;
    super.initState();
  }

  bool isTitleNotEmpty() {
    return titleController.text.isNotEmpty;
  }

  askConfirmationBeforeDeletingNote() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                HapticFeedback.mediumImpact();

                Navigator.of(context).pop(); // Close the dialog
                widget.helper.deleteANote(widget.notes);
                Navigator.of(context).pop(); // going back to home

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Note deleted!"),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(
            readOnly ? Icons.edit : Icons.save,
            color: Colors.black,
          ),
          onPressed: () {
            HapticFeedback.mediumImpact();

            setState(() {
              if (!readOnly) {
                if (isTitleNotEmpty()) {
                  widget.helper.updateANote(
                    Notes(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        color: widget.notes.color,
                        id: widget.notes.id),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Note updated"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                  HapticFeedback.mediumImpact();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Note title can't be left empty."),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  HapticFeedback.mediumImpact();
                  return;
                }
              }
              readOnly = !readOnly;
              if (readOnly) {
                Global.isEditingInProgress = false;
              } else {
                Global.isEditingInProgress = true;
              }
            });
          }),
      backgroundColor: widget.noteColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(12.0)),
          child: AppBar(
            actions: [
              IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  askConfirmationBeforeDeletingNote();
                },
                icon: Icon(
                  Icons.delete_rounded,
                  color: Colors.red.shade700,
                ),
              ),
            ],
            elevation: 4,
            backgroundColor: widget.noteColor,
            title: Hero(
              tag: widget.notes.id.toString(),
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: titleController,
                  readOnly: readOnly,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                  maxLines: 1,
                  decoration: const InputDecoration(border: InputBorder.none),
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
                readOnly: readOnly,
                maxLines: 100,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
