// Copyright (c) 2024 LLM Journal. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../schemes/event.dart';
import '../components/bottom_sheet.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The initial screen of the application that displays today's events and AI-generated advice.
/// 
/// Provides a quick overview of the user's schedule and personalized recommendations.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

/// The state for the StartScreen widget.
/// 
/// Manages the loading and display of today's events and AI-generated advice.
class _StartScreenState extends State<StartScreen> {
  final ApiService _apiService = ApiService();

  late Future<List<Event>> _eventsFuture;
  late Future<String> _adviceFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Initializes all data loading futures for the start screen.
  void _loadData() {
    _eventsFuture = _apiService.getEventsToday();
    _adviceFuture = _apiService.getAdviceToday();
  }

  /// Formats a DateTime object into a 12-hour time string with AM/PM.
  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0, bottom: 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Events today', style: Theme.of(context).textTheme.headlineMedium),
                Image.asset('lib/assets/icon.png', width: 32, height: 32),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: \\${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No events for today.');
                }
                final events = snapshot.data!;
                return Column(
                  children: [
                    ...events.map((event) => Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: ListTile(
                            leading: Icon(CupertinoIcons.calendar, color: Theme.of(context).colorScheme.primary),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "${_formatTime(event.startTime)}\n",
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      TextSpan(
                                        text: event.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  event.description,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  softWrap: true,
                                ),
                              ],
                            ),
                            subtitle: const Text('→ click for advice'),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                ),
                                isScrollControlled: true,
                                builder: (context) => EventBottomSheet(event: event),
                              );
                            },
                          ),
                        )),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Text('Advice for today', style: Theme.of(context).textTheme.headlineMedium),
            Divider(thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _adviceFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: \\${snapshot.error}');
                }
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    // Markdown kasten
                    child: MarkdownBody(
                      data: snapshot.data ?? '',
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyLarge,
                        h1: Theme.of(context).textTheme.headlineSmall,
                        h2: Theme.of(context).textTheme.titleLarge,
                        strong: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 