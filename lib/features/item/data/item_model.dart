import 'package:dart_server/core/models/base_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class Item implements BaseModel {
  @override
  ObjectId? id;
  String? name;
  String? description;
  @override
  DateTime? createdAt;
  @override
  DateTime? updatedAt;

  Item({this.id, this.name, this.description, this.createdAt, this.updatedAt});

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id?.oid,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  void fromJson(Map<String, dynamic> json) {
    id =
        json['_id'] != null
            ? (json['_id'] is ObjectId
                ? json['_id']
                : ObjectId.parse(json['_id']))
            : null;

    name = json['name']?.toString(); // Convert to String if not null
    description = json['description']?.toString();

    createdAt =
        json['createdAt'] != null
            ? (json['createdAt'] is DateTime
                ? json['createdAt']
                : DateTime.parse(json['createdAt']))
            : null;

    updatedAt =
        json['updatedAt'] != null
            ? (json['updatedAt'] is DateTime
                ? json['updatedAt']
                : DateTime.parse(json['updatedAt']))
            : null;
  }

  static Item fromMap(Map<String, dynamic> map) {
    final item = Item();
    item.fromJson(map);
    return item;
  }
}
