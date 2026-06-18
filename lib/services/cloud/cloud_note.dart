class CloudNote {
  final String documentId;
  final String ownerUserId;
  final String text;

  CloudNote({
    required this.documentId,
    required this.ownerUserId,
    required this.text,
  });

  CloudNote.fromSnapshot(Map<String, dynamic> snapshot, String documentId)
      : documentId = documentId,
        ownerUserId = snapshot['ownerUserId'] as String,
        text = snapshot['text'] as String;
}