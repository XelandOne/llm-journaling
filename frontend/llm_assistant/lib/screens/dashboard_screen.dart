// Copyright (c) 2024 LLM Journal. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../services/api_service.dart';
import '../schemes/feeling.dart';
import '../services/audio_service.dart';
import '../schemes/event.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A screen that displays a dashboard of the user's emotional state and activities
/// over the past week, including AI-generated feedback and motivational content.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// The state for the DashboardScreen widget.
/// 
/// Manages the loading and display of weekly statistics, feelings analysis,
/// and AI-generated feedback.
class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  final AudioService _audioService = AudioService();
  late Future<List<Feeling>> _feelingsFuture;
  late Future<List<Event>> _eventsFuture;
  late Future<String> _aiFeedbackFuture;
  late Future<void> _preloadAudioFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Initializes all data loading futures for the dashboard.
  void _loadData() {
    _feelingsFuture = _apiService.getFeelingsLastWeek();
    _eventsFuture = _apiService.getEventsLastWeek();
    _aiFeedbackFuture = _apiService.getAiFeedbackLastWeek();
    _preloadAudioFuture = _audioService.preloadMotivationalSpeech();
  }

  /// Handles the play/pause of the motivational speech audio.
  Future<void> _handleMotivationalSpeech() async {
    try {
      if (_audioService.isPlaying) {
        await _audioService.pauseMotivationalSpeech();
      } else {
        await _audioService.playMotivationalSpeech();
      }
      setState(() {}); // Update UI to reflect playing state
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing motivational speech: $e')),
        );
      }
    }
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
                Text('Your last week in stats', style: Theme.of(context).textTheme.headlineMedium),
                Image.asset('lib/assets/icon.png', width: 32, height: 32),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            FutureBuilder<List<Feeling>>(
              future: _feelingsFuture,
              builder: (context, feelingsSnapshot) {
                if (feelingsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (feelingsSnapshot.hasError) {
                  return Text('Error: ${feelingsSnapshot.error}');
                } else if (!feelingsSnapshot.hasData || feelingsSnapshot.data!.isEmpty) {
                  return const Text('No feelings data for last week.');
                }

                final feelings = feelingsSnapshot.data!;
                
                // Calculate feeling-based metrics
                final prodScores = feelings.where((f) => f.feelings.contains('motivated')).map((f) => f.score).toList();
                final anxScores = feelings.where((f) => f.feelings.contains('anxious')).map((f) => f.score).toList();
                final happyScores = feelings.where((f) => f.feelings.contains('happy')).map((f) => f.score).toList();
                final calmScores = feelings.where((f) => f.feelings.contains('calm')).map((f) => f.score).toList();
                
                // Calculate averages
                final prodAvg = prodScores.isNotEmpty ? prodScores.reduce((a, b) => a + b) / prodScores.length : 0.0;
                final anxAvg = anxScores.isNotEmpty ? anxScores.reduce((a, b) => a + b) / anxScores.length : 0.0;
                final happyAvg = happyScores.isNotEmpty ? happyScores.reduce((a, b) => a + b) / happyScores.length : 0.0;
                final calmAvg = calmScores.isNotEmpty ? calmScores.reduce((a, b) => a + b) / calmScores.length : 0.0;

                // Calculate emotional balance (positive vs negative feelings)
                final positiveFeelings = feelings.where((f) => 
                  f.feelings.any((feeling) => ['happy', 'calm', 'relaxed', 'excited', 'motivated'].contains(feeling))
                ).length;
                final negativeFeelings = feelings.where((f) => 
                  f.feelings.any((feeling) => ['sad', 'angry', 'anxious', 'stressed', 'tired'].contains(feeling))
                ).length;
                final emotionalBalance = positiveFeelings + negativeFeelings > 0 
                  ? (positiveFeelings / (positiveFeelings + negativeFeelings)) * 10 
                  : 5.0;

                return FutureBuilder<List<Event>>(
                  future: _eventsFuture,
                  builder: (context, eventsSnapshot) {
                    if (eventsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final events = eventsSnapshot.data ?? [];
                    
                    // Calculate event-based metrics
                    final workEvents = events.where((e) => e.tags.contains('work')).length;
                    final healthEvents = events.where((e) => e.tags.contains('health')).length;
                    final socialEvents = events.where((e) => e.tags.contains('social')).length;
                    final totalEvents = events.length;
                    
                    // Calculate work-life balance (work events vs non-work events)
                    final workLifeBalance = totalEvents > 0 
                      ? ((totalEvents - workEvents) / totalEvents) * 10 
                      : 5.0;

                    return Column(
                      children: [
                        // Emotional Well-being Section
                        Text('Emotional Well-being', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.heart_fill, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 12),
                                _StatCircle(label: 'Happiness', value: happyAvg),
                                const SizedBox(width: 16),
                                _StatCircle(label: 'Calmness', value: calmAvg),
                                const SizedBox(width: 16),
                                _StatCircle(label: 'Balance', value: emotionalBalance),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Productivity & Stress Section
                        Text('Productivity & Stress', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.chart_bar_alt_fill, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 12),
                                _StatCircle(label: 'Productivity', value: prodAvg),
                                const SizedBox(width: 16),
                                _StatCircle(label: 'Anxiety', value: anxAvg),
                                const SizedBox(width: 16),
                                _StatCircle(label: 'Work-Life', value: workLifeBalance),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Activity Distribution Section
                        if (events.isNotEmpty) ...[
                          Text('Activity Distribution', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ActivityBar(label: 'Work', value: workEvents, total: totalEvents),
                                  const SizedBox(height: 8),
                                  _ActivityBar(label: 'Health', value: healthEvents, total: totalEvents),
                                  const SizedBox(height: 8),
                                  _ActivityBar(label: 'Social', value: socialEvents, total: totalEvents),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AI Feedback', style: Theme.of(context).textTheme.headlineMedium),
                FutureBuilder<void>(
                  future: _preloadAudioFuture,
                  builder: (context, snapshot) {
                    final isLoading = snapshot.connectionState == ConnectionState.waiting;
                    final hasError = snapshot.hasError;
                    
                    return ElevatedButton.icon(
                      onPressed: hasError ? null : _handleMotivationalSpeech,
                      icon: Icon(
                        isLoading 
                          ? CupertinoIcons.arrow_clockwise 
                          : (_audioService.isPlaying 
                              ? CupertinoIcons.pause_fill 
                              : CupertinoIcons.play_fill)
                      ),
                      label: Text(
                        isLoading 
                          ? 'Loading...' 
                          : (_audioService.isPlaying 
                              ? 'Pause Speech' 
                              : 'Play Motivational Speech')
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                    );
                  },
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: _aiFeedbackFuture,
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

class _StatCircle extends StatelessWidget {
  final String label;
  final double value; // 0-10
  const _StatCircle({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final percent = (value / 10).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percent,
                strokeWidth: 7,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
              Text('${(value * 10).round() ~/ 10}', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  final String label;
  final int value;
  final int total;

  const _ActivityBar({required this.label, required this.value, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? value / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text('$value events', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
} 