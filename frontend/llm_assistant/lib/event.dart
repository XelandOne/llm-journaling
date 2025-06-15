class Event {
  final String date;
  final DateTime startTime;
  final DateTime endTime;
  final String description;
  final List<String> tags;
  final String name;

  Event({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.tags,
    required this.name,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: json['date'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      description: json['description'],
      tags: List<String>.from(json['tags'] ?? []),
      name: json['name']
    );
  }
} 