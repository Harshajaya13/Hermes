import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Block {
  final String id;
  final String domainId;
  final String name;
  final String description;
  final String icon;
  final String colorHex;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool archived;
  final bool deleted;
  final bool pinned;
  final int version;

  Block({
    String? id,
    required this.domainId,
    required this.name,
    this.description = '',
    this.icon = '📘',
    this.colorHex = '#7C9EBC', // Default accent color from theme
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.archived = false,
    this.deleted = false,
    this.pinned = false,
    this.version = 1,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'domainId': domainId,
        'name': name,
        'description': description,
        'icon': icon,
        'colorHex': colorHex,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
        'archived': archived,
        'deleted': deleted,
        'pinned': pinned,
        'version': version,
      };

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        id: json['id'] as String,
        domainId: json['domainId'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '📘',
        colorHex: json['colorHex'] as String? ?? '#7C9EBC',
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
        archived: json['archived'] as bool? ?? false,
        deleted: json['deleted'] as bool? ?? false,
        pinned: json['pinned'] as bool? ?? false,
        version: json['version'] as int? ?? 1,
      );

  Block copyWith({
    String? domainId,
    String? name,
    String? description,
    String? icon,
    String? colorHex,
    DateTime? modifiedAt,
    bool? archived,
    bool? deleted,
    bool? pinned,
    int? version,
  }) {
    return Block(
      id: id,
      domainId: domainId ?? this.domainId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      pinned: pinned ?? this.pinned,
      version: version ?? (this.version + 1),
    );
  }
}
