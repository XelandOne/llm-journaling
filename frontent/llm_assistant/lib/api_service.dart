import 'dart:convert';
import 'package:http/http.dart' as http;
import 'event.dart';
import 'feeling.dart';
import 'chat_response.dart';

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
      return response.body;
    } else {
      throw Exception('Failed to load advice');
    }
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
      return response.body;
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
} 