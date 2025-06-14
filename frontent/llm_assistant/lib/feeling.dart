class Feeling {
  final List<String> feelings;
  final int score;
  final DateTime datetime;

  Feeling({
    required this.feelings,
    required this.score,
    required this.datetime,
  });

  factory Feeling.fromJson(Map<String, dynamic> json) {
    return Feeling(
      feelings: List<String>.from(json['feelings'] ?? []),
      score: json['score'],
      datetime: DateTime.parse(json['datetime']),
    );
  }
} 