import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gnotes/global/global.dart';
import 'package:gnotes/home/presentation/new_note.dart';
import 'package:gnotes/home/presentation/particular_note.dart';
import 'package:gnotes/models/notes.dart';
import 'package:gnotes/util/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DbHelper helper = DbHelper();
  List<Notes>? notesList;

  Future showData() async {
    await helper.openDb();
    notesList = await helper.getAllNotes();
    setState(() {
      notesList = notesList;
    });
    // Notes note = Notes(
    //     title: "i am the title", description: "i am the description", id: 0);
    // int? noteId = await helper.insertANote(note);
    // print('Note Id: ' + noteId.toString());
  }

  void deleteTheNote(Notes currentNote, int index) {
    notesList?.removeAt(index);
    helper.deleteANote(currentNote);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Note deleted!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
    HapticFeedback.mediumImpact();
  }

  void askConfirmationBeforeDeletingNote(Notes currentNote, int index) {
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
                Navigator.of(context).pop(); // Close the dialog
                deleteTheNote(currentNote, index);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    showData();
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.add,
              color: Colors.black,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewNoteScreen(
                    noteColor: Global.tileColors[(notesList != null)
                        ? notesList!.length % (Global.tileColors.length)
                        : 0],
                    helper: helper,
                  ),
                ),
              );
            }),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: AppBar(
              backgroundColor: Colors.white,
              title: const Text(
                Global.appTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              elevation: 4,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: (notesList != null && notesList!.isEmpty)
              ? const Center(
                  child: Text(
                    "Click on '+' button to create a note.",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: (notesList != null) ? notesList?.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    var currentItem = notesList![index];
                    return Dismissible(
                      key: Key((currentItem.id ?? index).toString()),
                      onDismissed: (direction) {
                        deleteTheNote(currentItem, index);
                      },
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        color: Global
                            .tileColors[index % (Global.tileColors.length)],
                        child: ListTile(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ParticularNoteScreen(
                                  notes: currentItem,
                                  helper: helper,
                                  noteColor: Global.tileColors[
                                      index % (Global.tileColors.length)],
                                ),
                              ),
                            );
                          },
                          onLongPress: () {
                            // HapticFeedback.selectionClick();
                            askConfirmationBeforeDeletingNote(
                                currentItem, index);
                          },
                          dense: false,
                          enableFeedback: true,
                          // minTileHeight: 30,
                          // style: ListTileStyle.list,

                          // tileColor:
                          //     Global.tileColors[index % (Global.tileColors.length)],
                          //tileColor: Color(int.parse(currentItem.color)),
                          title: Hero(
                            tag: currentItem.id.toString(),
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                currentItem.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          leading: CircleAvatar(
                            child: Text(
                              currentItem.title
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ));
  }
}
