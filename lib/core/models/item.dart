import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum ItemType { question, article, note, quote, observation, idea }

class Item {
  final String id;
  final String blockId;
  final ItemType type;
  final String title;
  final String content; // JSON string or markdown depending on engine
  final String? sourceUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final int version;

  Item({
    String? id,
    required this.blockId,
    required this.type,
    required this.title,
    required this.content,
    this.sourceUrl,
    this.metadata,
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
        'blockId': blockId,
        'type': type.name,
        'title': title,
        'content': content,
        'sourceUrl': sourceUrl,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'version': version,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        blockId: json['blockId'] as String,
        type: ItemType.values.byName(json['type'] as String),
        title: json['title'] as String,
        content: json['content'] as String,
        sourceUrl: json['sourceUrl'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
      );

  Item copyWith({
    String? title,
    String? content,
    String? sourceUrl,
    Map<String, dynamic>? metadata,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    int? version,
  }) {
    return Item(
      id: id,
      blockId: blockId,
      type: type,
      title: title ?? this.title,
      content: content ?? this.content,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      version: version ?? (this.version + 1),
    );
  }
}
