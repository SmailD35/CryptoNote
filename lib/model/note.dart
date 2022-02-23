const String tableName = 'crypto_note';

class NoteFields {
  static final List<String> values = [
    id, address, comment, owner, time
  ];

  static const String id = '_id';
  static const String address = 'address';
  static const String comment = 'comment';
  static const String owner = 'owner';
  static const String time = 'time';
}

class Note {
  final int? id;
  final String address;
  final String comment;
  final String owner;
  final DateTime time;

  const Note({
    this.id,
    required this.address,
    required this.comment,
    required this.owner,
    required this.time,
  });

  Note copy({
    int? id,
    String? address,
    String? comment,
    String? owner,
    DateTime? time,
  }) =>
      Note(
        id: id ?? this.id,
        address: address ?? this.address,
        comment: comment ?? this.comment,
        owner: owner ?? this.owner,
        time: time ?? this.time,
      );

  Map<String, Object?> toJSON() => {
    NoteFields.id: id,
    NoteFields.address: address,
    NoteFields.comment: comment,
    NoteFields.owner: owner,
    NoteFields.time: time.toIso8601String(),
  };

  static Note fromJSON(Map<String, Object?> json) => Note(
    id: json[NoteFields.id] as int?,
    address: json[NoteFields.address] as String,
    comment: json[NoteFields.comment] as String,
    owner: json[NoteFields.owner] as String,
    time: DateTime.parse(json[NoteFields.time] as String),
  );
}
