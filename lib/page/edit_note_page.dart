import 'package:flutter/material.dart';
import 'package:crypto_note/db/crypto_database.dart';
import 'package:crypto_note/model/note.dart';
import 'package:crypto_note/widget/note_form_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({
    Key? key,
    this.note,
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late String address;
  late String comment;
  late String owner;

  @override
  void initState() {
    super.initState();

    address = widget.note?.address ?? '';
    comment = widget.note?.comment ?? '';
    owner = widget.note?.owner ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: NoteFormWidget(
        address: address,
        owner: owner,
        comment: comment,
        onChangedAddress: (address) => setState(() => this.address = address),
        onChangedOwner: (owner) => setState(() => this.owner = owner),
        onChangedComment: (comment) => setState(() => this.comment = comment),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = address.isNotEmpty && comment.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNote,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      address: address,
      comment: comment,
      owner: owner,
    );

    await CryptoDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Note(
      address: address,
      comment: comment,
      owner: owner,
      time: DateTime.now(),
    );

    await CryptoDatabase.instance.create(note);
  }
}
