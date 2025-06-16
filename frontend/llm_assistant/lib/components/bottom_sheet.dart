// Copyright (c) 2024 LLM Journal. All rights reserved.

import 'package:flutter/material.dart';
import '../schemes/event.dart';
import '../services/api_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// A bottom sheet widget that displays detailed information about an event.
/// 
/// Shows the event's details and AI-generated advice in a draggable sheet that
/// can be expanded or collapsed.
class EventBottomSheet extends StatefulWidget {
  /// The event to display in the bottom sheet.
  final Event event;

  /// Creates a new [EventBottomSheet] instance.
  const EventBottomSheet({super.key, required this.event});

  @override
  State<EventBottomSheet> createState() => _EventBottomSheetState();
}

/// The state for the EventBottomSheet widget.
/// 
/// Manages the loading and display of event details and AI-generated advice.
class _EventBottomSheetState extends State<EventBottomSheet> {
  final ApiService _apiService = ApiService();
  late Future<String> _adviceFuture;

  @override
  void initState() {
    super.initState();
    _adviceFuture = _apiService.getEventAdvice(widget.event);
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
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(widget.event.startTime),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.event.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'Advice',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  future: _adviceFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}