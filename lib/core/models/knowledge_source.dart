import 'package:uuid/uuid.dart';

const _uuid = Uuid();

enum SourceType { manualQuestion, manualArticle, community, rss }

class KnowledgeSource {
  final String id;
  final String workspaceId;
  final String name;
  final SourceType type;
  final String targetDomainId;
  final String targetBlockId;
  final bool includeInToday;
  final int dailyLimit;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final Map<String, dynamic>? metadata;

  KnowledgeSource({
    String? id,
    required this.workspaceId,
    required this.name,
    required this.type,
    required this.targetDomainId,
    required this.targetBlockId,
    this.includeInToday = true,
    this.dailyLimit = 3,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.archived = false,
    this.deleted = false,
    this.metadata,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'name': name,
        'type': type.name,
        'targetDomainId': targetDomainId,
        'targetBlockId': targetBlockId,
        'includeInToday': includeInToday,
        'dailyLimit': dailyLimit,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'metadata': metadata,
      };

  factory KnowledgeSource.fromJson(Map<String, dynamic> json) => KnowledgeSource(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        name: json['name'] as String,
        type: SourceType.values.byName(json['type'] as String),
        targetDomainId: json['targetDomainId'] as String,
        targetBlockId: json['targetBlockId'] as String,
        includeInToday: json['includeInToday'] as bool? ?? true,
        dailyLimit: json['dailyLimit'] as int? ?? 3,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  KnowledgeSource copyWith({
    String? workspaceId,
    String? name,
    String? targetDomainId,
    String? targetBlockId,
    bool? includeInToday,
    int? dailyLimit,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    Map<String, dynamic>? metadata,
  }) {
    return KnowledgeSource(
      id: id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      type: type,
      targetDomainId: targetDomainId ?? this.targetDomainId,
      targetBlockId: targetBlockId ?? this.targetBlockId,
      includeInToday: includeInToday ?? this.includeInToday,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      metadata: metadata ?? this.metadata,
    );
  }
}
