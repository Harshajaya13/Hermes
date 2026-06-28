import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Workspace {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String visibility; // 'public', 'private'
  final bool isEncrypted;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final int version;

  Workspace({
    String? id,
    required this.name,
    this.description = '',
    this.icon = '📖',
    this.visibility = 'public',
    this.isEncrypted = false,
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
        'name': name,
        'description': description,
        'icon': icon,
        'visibility': visibility,
        'isEncrypted': isEncrypted,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'version': version,
      };

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '📖',
        visibility: json['visibility'] as String? ?? 'public',
        isEncrypted: json['isEncrypted'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
      );

  Workspace copyWith({
    String? name,
    String? description,
    String? icon,
    String? visibility,
    bool? isEncrypted,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    int? version,
  }) {
    return Workspace(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      visibility: visibility ?? this.visibility,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      version: version ?? (this.version + 1),
    );
  }
}
