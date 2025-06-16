// Copyright (c) 2024 LLM Journal. All rights reserved.

import 'event.dart';
import 'feeling.dart';

/// Represents the AI's response to a user's chat message.
/// 
/// Contains the AI's text response, detected feelings, and any events that were created
/// as a result of the conversation.
class ChatResponse {
  /// The event that triggered this chat response, if any.
  final Event? event;
  
  /// A list of feelings detected in the user's message.
  final List<Feeling>? feeling;
  
  /// The AI's text response to the user's message.
  final String? response;
  
  /// A list of events created based on the conversation.
  final List<Event>? createdEvents;

  /// Creates a new [ChatResponse] instance.
  const ChatResponse({
    this.event,
    this.feeling,
    this.response,
    this.createdEvents,
  });

  /// Creates a [ChatResponse] instance from a JSON map.
  /// 
  /// Used for deserializing chat response data from the API response.
  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      feeling: json['feeling'] != null
          ? (json['feeling'] is List
              ? List<Feeling>.from((json['feeling'] as List).map((f) => Feeling.fromJson(f)))
              : [Feeling.fromJson(json['feeling'])])
          : null,
      response: json['response'],
      createdEvents: json['created_events'] != null
          ? List<Event>.from(
              (json['created_events'] as List).map((e) => Event.fromJson(e)))
          : null,
    );
  }
} 