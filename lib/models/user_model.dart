import 'dart:convert';

class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? fcmToken;
  final String? gender;
  final String? profilePicture;
  final bool? enablePushNotification;

  UserModel._({
    this.id,
    this.name,
    this.email,
    this.fcmToken,
    this.gender,
    this.profilePicture,
    this.enablePushNotification,
  });

  UserModel.newUser({
    this.id,
    this.name,
    this.email,
    this.fcmToken,
    this.gender,
    this.profilePicture,
    this.enablePushNotification,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? country,
    String? fcmToken,
    String? gender,
    String? profilePicture,
    bool? enablePushNotification,
  }) {
    return UserModel._(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      fcmToken: fcmToken ?? this.fcmToken,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
      enablePushNotification:
          enablePushNotification ?? this.enablePushNotification,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'fcmToken': fcmToken,
      'gender': gender,
      'profile_picture': profilePicture,
      'enablePushNotification': enablePushNotification,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel._(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      fcmToken: map['fcmToken'],
      gender: map['gender'],
      profilePicture: map['profile_picture'],
      enablePushNotification: map['enablePushNotification'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
