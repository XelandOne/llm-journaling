// Copyright (c) 2024 LLM Journal. All rights reserved.

/// Represents an event in the user's schedule.
/// 
/// Contains information about the event's timing, description, and categorization.
class Event {
  /// The date of the event in a human-readable format.
  final String date;
  
  /// The start time of the event.
  final DateTime startTime;
  
  /// The end time of the event.
  final DateTime endTime;
  
  /// A detailed description of the event.
  final String description;
  
  /// A list of tags categorizing the event.
  final List<String> tags;
  
  /// The name or title of the event.
  final String name;

  /// Creates a new [Event] instance.
  const Event({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.tags,
    required this.name,
  });

  /// Creates an [Event] instance from a JSON map.
  /// 
  /// Used for deserializing event data from the API response.
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