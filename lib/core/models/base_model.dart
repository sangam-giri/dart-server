import 'package:mongo_dart/mongo_dart.dart';

abstract class BaseModel {
  ObjectId? id;
  DateTime? createdAt;
  DateTime? updatedAt;

  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
}
