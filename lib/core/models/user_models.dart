import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class UserModel {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String email;

  @HiveField(2)
  @JsonKey(name: 'first_name')
  String firstName;

  @JsonKey(name: 'last_name')
  @HiveField(3)
  String lastName;

  @HiveField(4)
  String avatar;

  @HiveField(5)
  String? job;

  UserModel(
      {required this.id,
      required this.email,
      required this.firstName,
      required this.lastName,
      required this.avatar,
      required this.job});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
