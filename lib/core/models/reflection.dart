import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Reflection {
  final String id;
  final String itemId;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final int version;

  Reflection({
    String? id,
    required this.itemId,
    required this.content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.archived = false,
    this.deleted = false,
    this.version = 1,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'version': version,
      };

  factory Reflection.fromJson(Map<String, dynamic> json) => Reflection(
        id: json['id'] as String,
        itemId: json['itemId'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
      );

  Reflection copyWith({
    String? content,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    int? version,
  }) {
    return Reflection(
      id: id,
      itemId: itemId,
      content: content ?? this.content,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      version: version ?? (this.version + 1),
    );
  }
}
