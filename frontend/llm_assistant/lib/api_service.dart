import 'dart:convert';
import 'package:http/http.dart' as http;
import 'event.dart';
import 'feeling.dart';
import 'chat_response.dart';
import 'dart:typed_data';

class ApiService {
  static const String baseUrl = 'http://0.0.0.0:8000'; // TODO: Set your backend URL

  Future<List<Event>> getEventsToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    final response = await http.get(Uri.parse('$baseUrl/getEvents?startTime=$start&endTime=$end'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<String> getAdviceToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    final response = await http.get(Uri.parse('$baseUrl/getAdvice?startTime=$start&endTime=$end'));
    if (response.statusCode == 200) {
      return decodeEscapedNewlines(trimQuotes(response.body));
    } else {
      throw Exception('Failed to load advice');
    }
  }

  String trimQuotes(String input) {
    input = input.trim();
    if (input.startsWith('"') && input.endsWith('"')) {
      return input.substring(1, input.length - 1);
    }
    return input;
  }

  String decodeEscapedNewlines(String input) {
    return input.replaceAll(r'\n', '\n');
  }

  Future<List<Feeling>> getFeelingsLastWeek() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7)).toIso8601String();
    final end = now.toIso8601String();
    final response = await http.get(Uri.parse('$baseUrl/getFeelings?startTime=$start&endTime=$end'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Feeling.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load feelings');
    }
  }

  Future<String> getAiFeedbackLastWeek() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7)).toIso8601String();
    final end = now.toIso8601String();
    final response = await http.get(Uri.parse('$baseUrl/getAdvice?startTime=$start&endTime=$end'));
    if (response.statusCode == 200) {
      return trimQuotes(response.body);
    } else {
      throw Exception('Failed to load AI feedback');
    }
  }

  Future<ChatResponse> submitChat(String chat) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lifeChat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'chat': chat}),
    );
    if (response.statusCode == 200) {
      return ChatResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to submit chat');
    }
  }

  Future<Uint8List> getMotivationalSpeechLastWeek() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7)).toIso8601String();
    final end = now.toIso8601String();
    final response = await http.get(
      Uri.parse('$baseUrl/getMotivationalSpeech?startTime=$start&endTime=$end'),
      headers: {'Accept': 'audio/mpeg'},
    );
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load motivational speech');
    }
  }

  Future<String> getEventAdvice(Event event) async {
    final response = await http.get(Uri.parse('$baseUrl/getAdvice?startTime=${event.startTime}&endTime=${event.endTime}'));
    if (response.statusCode == 200) {
      return decodeEscapedNewlines(trimQuotes(response.body));
    } else {
      throw Exception('Failed to load event advice');
    }
  }

  Future<List<Event>> getEventsLastWeek() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7)).toIso8601String();
    final end = now.toIso8601String();
    final response = await http.get(Uri.parse('$baseUrl/getEvents?startTime=$start&endTime=$end'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }
} 