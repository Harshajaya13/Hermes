import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Domain {
  final String id;
  final String workspaceId;
  final String name;
  final String description;
  final String icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final int version;

  Domain({
    String? id,
    required this.workspaceId,
    required this.name,
    this.description = '',
    this.icon = '📁',
    this.sortOrder = 0,
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
        'workspaceId': workspaceId,
        'name': name,
        'description': description,
        'icon': icon,
        'sortOrder': sortOrder,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'version': version,
      };

  factory Domain.fromJson(Map<String, dynamic> json) => Domain(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '📁',
        sortOrder: json['sortOrder'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
      );

  Domain copyWith({
    String? workspaceId,
    String? name,
    String? description,
    String? icon,
    int? sortOrder,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    int? version,
  }) {
    return Domain(
      id: id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      version: version ?? (this.version + 1),
    );
  }
}
