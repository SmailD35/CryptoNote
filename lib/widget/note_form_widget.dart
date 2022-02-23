import 'package:flutter/material.dart';

class NoteFormWidget extends StatelessWidget {
  final String? address;
  final String? owner;
  final String? comment;
  final ValueChanged<String> onChangedAddress;
  final ValueChanged<String> onChangedOwner;
  final ValueChanged<String> onChangedComment;

  const NoteFormWidget({
    Key? key,
    this.address = '',
    this.owner = '',
    this.comment = '',
    required this.onChangedAddress,
    required this.onChangedOwner,
    required this.onChangedComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAddress(),
          buildOwner(),
          const SizedBox(height: 8),
          buildComment(),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );

  Widget buildAddress() => Row(
    children: [
      const Text(
        'Address: ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
        ),
      ),
      Flexible(
        child:
          TextFormField(
            maxLines: null,
            initialValue: address,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter address',
              hintStyle: TextStyle(color: Colors.white70),
            ),
            validator: (title) =>
              title != null && title.isEmpty ? 'The address cannot be empty' : null,
            onChanged: onChangedAddress,
          ),
      ),
    ]
  );

  Widget buildOwner() => Row(
      children: [
        const Text(
          'Owner: ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        Flexible(
          child:
            TextFormField(
              maxLines: null,
              initialValue: owner,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter owner',
                hintStyle: TextStyle(color: Colors.white70),
              ),
              onChanged: onChangedOwner,
            ),
        ),
      ]
  );

  Widget buildComment() => TextFormField(
    maxLines: null,
    initialValue: comment,
    style: const TextStyle(color: Colors.white60, fontSize: 18),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Type something...',
      hintStyle: TextStyle(color: Colors.white60),
    ),
    validator: (title) => title != null && title.isEmpty
        ? 'The comment cannot be empty'
        : null,
    onChanged: onChangedComment,
  );
}
