class User {
  int? id;
  String? name;
  int? timestamp;
  String? language;

  User({
    this.id,
    required this.name,
    required this.timestamp,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'User_Name': name,
      'Login_Time': timestamp,
      'Language': language,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['User_Name'],
      timestamp: map['Login_Time'],
      language: map['Language'],
    );
  }

  // fromJson parameter as a String

  User.fromJson(String _json) {
    final Map<String, dynamic> json = _json as Map<String, dynamic>;
    id = json['id'];
    name = json['User_Name'];
    timestamp = json['Login_Time'];
    language = json['Language'];
  }

  // toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['User_Name'] = name;
    data['Login_Time'] = timestamp;
    data['Language'] = language;
    return data;
  }
}
