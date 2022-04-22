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

  bool isSearchOpen = false;
  String searchAddress = '';
  String searchOwner = '';

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

  Future searchNotes() async {
    setState(() => isLoading = true);

    notes = await CryptoDatabase.instance.searchNotes(searchAddress, searchOwner);
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
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Search',
          onPressed: () {
            setState(() => isSearchOpen = !isSearchOpen);
          },
        ),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        child: isSearchOpen
            ?
              Padding(padding: const EdgeInsets.all(16.0), child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Address:', style: TextStyle(color: Colors.white, fontSize: 18),),
                      const SizedBox(width: 10,),
                      Expanded(child: TextField(
                        onChanged: (value) => setState(() => searchAddress = value),
                        style: const TextStyle(color: Colors.white),
                      ),),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Owner:', style: TextStyle(color: Colors.white, fontSize: 18),),
                      const SizedBox(width: 10,),
                      Expanded(child: TextField(
                        onChanged: (value) => setState(() => searchOwner = value),
                        style: const TextStyle(color: Colors.white),
                      ),),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  SizedBox(
                      width: 250,
                      height: 36,
                      child: ElevatedButton(
                          onPressed: () => searchNotes(),
                          child: const Text('Search', style: TextStyle(
                              fontSize: 16,
                            ),
                          )
                      )
                  ),
                ],
              ),)
            :
              Container(),
        preferredSize: Size.fromHeight(isSearchOpen ? 186 : 0),
      ),
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
    return !isLoading && noteItems.isNotEmpty ? ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          noteItems[index].isExpanded = !isExpanded;
        });
      },
      children: buildNotes(),
    ) : const Center(
          heightFactor: 2,
          child:
            Text(
              'No Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            )
        );
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
