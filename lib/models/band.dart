class Band{
  final String id;
  final String name;
  final int votes;

  const Band({
    required this.id,
    required this.name,
    required this.votes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'votes': this.votes,
    };
  }

  factory Band.fromMap(Map<String, dynamic> map) {
    return Band(
      id: map['id'] as String,
      name: map['name'] as String,
      votes: map['votes'] as int,
    );
  }
}