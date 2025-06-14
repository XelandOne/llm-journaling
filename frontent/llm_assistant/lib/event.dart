class Event {
  final String date;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final List<String> tags;

  Event({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.tags,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: json['date'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
} 