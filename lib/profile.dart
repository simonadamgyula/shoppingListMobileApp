class Profile {
  final String id;
  final String username;

  const Profile({required this.id, required this.username});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": String id, "username": String username} =>
          Profile(id: id, username: username),
      _ => throw const FormatException('Failed to load item.'),
    };
  }
}