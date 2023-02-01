import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Equatable {
  final String name;

  User({
    required this.name,
  }) : super();

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  // TODO: implement props
  List<Object?> get props => ['name'];
}