class FileItem {
  final int? id;
  final int projectId;
  final String name;
  final String content;
  final String language;
  final DateTime lastModified;

  FileItem({
    this.id,
    required this.projectId,
    required this.name,
    required this.content,
    required this.language,
    required this.lastModified,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'content': content,
      'language': language,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  factory FileItem.fromMap(Map<String, dynamic> map) {
    return FileItem(
      id: map['id'],
      projectId: map['projectId'],
      name: map['name'],
      content: map['content'],
      language: map['language'],
      lastModified: DateTime.parse(map['lastModified']),
    );
  }

  FileItem copyWith({
    int? id,
    int? projectId,
    String? name,
    String? content,
    String? language,
    DateTime? lastModified,
  }) {
    return FileItem(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      content: content ?? this.content,
      language: language ?? this.language,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
