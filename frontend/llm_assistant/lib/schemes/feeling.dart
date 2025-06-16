// Copyright (c) 2024 LLM Journal. All rights reserved.

/// Represents a user's emotional state at a specific point in time.
/// 
/// Contains information about detected feelings, their intensity, and when they were recorded.
class Feeling {
  /// A list of emotions detected in the user's input.
  final List<String> feelings;
  
  /// A score indicating the intensity of the feelings (0-10).
  final int score;
  
  /// The timestamp when these feelings were recorded.
  final DateTime datetime;

  /// Creates a new [Feeling] instance.
  const Feeling({
    required this.feelings,
    required this.score,
    required this.datetime,
  });

  /// Creates a [Feeling] instance from a JSON map.
  /// 
  /// Used for deserializing feeling data from the API response.
  factory Feeling.fromJson(Map<String, dynamic> json) {
    return Feeling(
      feelings: List<String>.from(json['feelings'] ?? []),
      score: json['score'],
      datetime: DateTime.parse(json['datetime']),
    );
  }
} 