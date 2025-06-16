// Copyright (c) 2024 LLM Journal. All rights reserved.

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../schemes/event.dart';
import '../schemes/feeling.dart';
import '../schemes/chat_response.dart';

/// A service class that handles all API communication with the backend server.
/// 
/// Provides methods for fetching events, feelings, advice, and handling chat interactions.
class ApiService {
  /// The base URL of the backend server.
  /// TODO: Update this with your production backend URL
  static const String baseUrl = 'http://0.0.0.0:8000';

  /// Fetches all events for the current day.
  /// 
  /// Returns a list of [Event] objects representing the user's schedule for today.
  Future<List<Event>> getEventsToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    return _getEvents(start, end);
  }

  /// Fetches all events for the past week.
  /// 
  /// Returns a list of [Event] objects representing the user's schedule for the last 7 days.
  Future<List<Event>> getEventsLastWeek() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 7)).toIso8601String();
    final end = now.toIso8601String();
    return _getEvents(start, end);
  }

  /// Internal method to fetch events within a time range.
  Future<List<Event>> _getEvents(String start, String end) async {
    final response = await http.get(Uri.parse('$baseUrl/getEvents?startTime=$start&endTime=$end'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  /// Fetches AI-generated advice for the current day.
  Future<String> getAdviceToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, 0, 0, 0).toIso8601String();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();
    return _getAdvice(start, end);
  }

  /// Fetches AI-generated advice for a specific event.
  Future<String> getEventAdvice(Event event) async {
    return _getAdvice(event.startTime.toIso8601String(), event.endTime.toIso8601String());
  }

  /// Internal method to fetch advice within a time range.
  Future<String> _getAdvice(String start, String end) async {
    final response = await http.get(Uri.parse('$baseUrl/getAdvice?startTime=$start&endTime=$end'));
    if (response.statusCode == 200) {
      return decodeEscapedNewlines(trimQuotes(response.body));
    } else {
      throw Exception('Failed to load advice');
    }
  }

  /// Fetches feelings data for the past week.
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

  /// Fetches AI feedback for the past week.
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

  /// Submits a chat message to the AI and returns the response.
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

  /// Fetches a motivational speech audio for the past week.
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

  /// Removes surrounding quotes from a string if present.
  String trimQuotes(String input) {
    input = input.trim();
    if (input.startsWith('"') && input.endsWith('"')) {
      return input.substring(1, input.length - 1);
    }
    return input;
  }

  /// Replaces escaped newlines with actual newlines in a string.
  String decodeEscapedNewlines(String input) {
    return input.replaceAll(r'\n', '\n');
  }
} 