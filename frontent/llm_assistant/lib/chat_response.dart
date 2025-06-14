import 'event.dart';
import 'feeling.dart';

class ChatResponse {
  final Event? event;
  final Feeling? feeling;

  ChatResponse({this.event, this.feeling});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
      feeling: json['feeling'] != null ? Feeling.fromJson(json['feeling']) : null,
    );
  }
} 