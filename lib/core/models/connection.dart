import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Connection {
  final String id;
  final String itemAId;
  final String itemBId;
  final String title;
  final String note;
  final DateTime createdAt;
  final DateTime modifiedAt;

  Connection({
    String? id,
    required this.itemAId,
    required this.itemBId,
    required this.title,
    this.note = '',
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemAId': itemAId,
        'itemBId': itemBId,
        'title': title,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
        id: json['id'] as String,
        itemAId: json['itemAId'] as String,
        itemBId: json['itemBId'] as String,
        title: json['title'] as String,
        note: json['note'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
        modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      );

  Connection copyWith({
    String? title,
    String? note,
    DateTime? modifiedAt,
  }) {
    return Connection(
      id: id,
      itemAId: itemAId,
      itemBId: itemBId,
      title: title ?? this.title,
      note: note ?? this.note,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
    );
  }
}
