import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Veritas {
  final String id;
  final String workspaceId; // Veritas applies per-workspace
  final DateTime dateMissed;
  final String reason;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final int version;
  final bool hiddenFromHome;

  Veritas({
    String? id,
    required this.workspaceId,
    required this.dateMissed,
    required this.reason,
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
        'workspaceId': workspaceId,
        'dateMissed': dateMissed.toIso8601String(),
        'reason': reason,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'version': version,
        'hiddenFromHome': hiddenFromHome,
      };

  factory Veritas.fromJson(Map<String, dynamic> json) => Veritas(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        dateMissed: DateTime.parse(json['dateMissed'] as String),
        reason: json['reason'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
        hiddenFromHome: json['hiddenFromHome'] as bool? ?? false,
      );

  Veritas copyWith({
    String? reason,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    int? version,
    bool? hiddenFromHome,
  }) {
    return Veritas(
      id: id,
      workspaceId: workspaceId,
      dateMissed: dateMissed,
      reason: reason ?? this.reason,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      version: version ?? (this.version + 1),
      hiddenFromHome: hiddenFromHome ?? this.hiddenFromHome,
    );
  }
}
