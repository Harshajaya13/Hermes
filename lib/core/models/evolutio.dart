import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Evolutio {
  final String id;
  final String reflectionId;
  final String blockId; // Helps with quick lookups
  final String content; // The realization
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final int version;
  final bool hiddenFromHome;

  Evolutio({
    String? id,
    required this.reflectionId,
    required this.blockId,
    required this.content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.archived = false,
    this.deleted = false,
    this.version = 1,
    this.hiddenFromHome = false,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'reflectionId': reflectionId,
        'blockId': blockId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'version': version,
        'hiddenFromHome': hiddenFromHome,
      };

  factory Evolutio.fromJson(Map<String, dynamic> json) => Evolutio(
        id: json['id'] as String,
        reflectionId: json['reflectionId'] as String,
        blockId: json['blockId'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
        hiddenFromHome: json['hiddenFromHome'] as bool? ?? false,
      );

  Evolutio copyWith({
    String? content,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    int? version,
    bool? hiddenFromHome,
  }) {
    return Evolutio(
      id: id,
      reflectionId: reflectionId,
      blockId: blockId,
      content: content ?? this.content,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      version: version ?? (this.version + 1),
      hiddenFromHome: hiddenFromHome ?? this.hiddenFromHome,
    );
  }
}
