import 'package:flutter/material.dart';
import 'event.dart';

class EventBottomSheet extends StatelessWidget {
  final Event event;

  const EventBottomSheet({super.key, required this.event});

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
                  'Event Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 40),
                Text('Description: ${event.description}'),
                const SizedBox(height: 8),
                Text('Time: ${event.startTime}'),
                const SizedBox(height: 40),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'What you should recall before the event? \n \n First of all, recall it\'s a business event, so pick a business casual outfit Furthermore you should try to talk to Martin, the founder and network with other attendants.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 100),
                // Add more placeholders or content here if needed
              ],
            ),
          ),
        );
      },
    );
  }
}