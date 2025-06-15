import 'event.dart';
import 'feeling.dart';

class ChatResponse {
  final Event? event;
  final List<Feeling>? feeling;
  final String? response;
  final List<Event>? createdEvents;

  ChatResponse({this.event, this.feeling, this.response, this.createdEvents});

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