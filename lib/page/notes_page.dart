import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:crypto_note/db/crypto_database.dart';
import 'package:crypto_note/model/note.dart';
import 'package:crypto_note/page/edit_note_page.dart';
import 'package:crypto_note/page/note_detail_page.dart';
import 'package:crypto_note/widget/note_card_widget.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late List<Note> notes;
  late List<NoteCardItem> noteItems;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {
    CryptoDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await CryptoDatabase.instance.readAllNotes();
    noteItems = notes.map((note) => NoteCardItem(note)).toList();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'CryptoNote',
        style: TextStyle(fontSize: 24),
      ),
      actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: SingleChildScrollView(
      child: Container(
        child: _buildPanelsList(),
      ),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditNotePage()),
        );

        refreshNotes();
      },
    ),
  );

  Widget _buildPanelsList() {
    return !isLoading ? ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          noteItems[index].isExpanded = !isExpanded;
        });
      },
      children: buildNotes(),
    ) : const Text('No Notes');
  }

  List<ExpansionPanel> buildNotes() => noteItems.map<ExpansionPanel>((noteItem) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: !noteItem.isExpanded
              ?
                Text(noteItem.note.comment.length > 151
                    ?
                      '${noteItem.note.comment.substring(0, 150)}...'
                    :
                      noteItem.note.comment)
              :
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Address: ${noteItem.note.address}'),
                    if (noteItem.note.owner.isNotEmpty) Text('Owner: ${noteItem.note.owner}'),
                  ],
                ),
        );
      },
      body: ListTile(
        title: Text(noteItem.note.comment),
        subtitle: Text(DateFormat.yMMMd().format(noteItem.note.time)),
        onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteDetailPage(noteId: noteItem.note.id!),
            ));

            refreshNotes();
          }
        ),
      isExpanded: noteItem.isExpanded,
    );
  }).toList();
}
