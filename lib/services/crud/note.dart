class DatabaseNote {
  final int id;
  final String text;

  DatabaseNote({
    required this.id,
    required this.text,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map['id'] as int,
        text = map['text'] as String;
}