import 'package:flutter/material.dart';
import 'api_service.dart';
import 'event.dart';
import 'bottom_sheet.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final ApiService apiService = ApiService();

  late Future<List<Event>> _eventsFuture;
  late Future<String> _adviceFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = apiService.getEventsToday();
    _adviceFuture = apiService.getAdviceToday();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Events today', style: Theme.of(context).textTheme.headlineSmall),
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
                        child: ListTile(
                          title: Text(
                            '${_formatTime(event.startTime)}: ${event.description}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
          Text('Advice for today', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: _adviceFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: \\${snapshot.error}');
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: Text(snapshot.data ?? '', style: Theme.of(context).textTheme.bodyLarge),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }
} 