import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'api_service.dart';
import 'feeling.dart';
import 'audio_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService apiService = ApiService();
  final AudioService audioService = AudioService();
  late Future<List<Feeling>> _feelingsFuture;
  late Future<String> _aiFeedbackFuture;
  late Future<void> _preloadAudioFuture;

  @override
  void initState() {
    super.initState();
    _feelingsFuture = apiService.getFeelingsLastWeek();
    _aiFeedbackFuture = apiService.getAiFeedbackLastWeek();
    // Start preloading the audio immediately
    _preloadAudioFuture = audioService.preloadMotivationalSpeech();
  }

  Future<void> _handleMotivationalSpeech() async {
    try {
      if (audioService.isPlaying) {
        await audioService.pauseMotivationalSpeech();
      } else {
        await audioService.playMotivationalSpeech();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0, bottom: 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your last week in stats', style: Theme.of(context).textTheme.headlineMedium),
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            FutureBuilder<List<Feeling>>(
              future: _feelingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: \\${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No data for last week.');
                }
                final feelings = snapshot.data!;
                // For demo: Productivity = avg of 'motivated', Anxiety = avg of 'anxious'
                final prodScores = feelings.where((f) => f.feelings.contains('motivated')).map((f) => f.score).toList();
                final anxScores = feelings.where((f) => f.feelings.contains('anxious')).map((f) => f.score).toList();
                final prodAvg = prodScores.isNotEmpty ? prodScores.reduce((a, b) => a + b) / prodScores.length : 0.0;
                final anxAvg = anxScores.isNotEmpty ? anxScores.reduce((a, b) => a + b) / anxScores.length : 0.0;
                return Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.chart_bar_alt_fill, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            _StatCircle(label: 'Productivity', value: prodAvg.toDouble()),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                prodAvg > 7 ? 'Your productivity was very high' : 'Your productivity was moderate',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.waveform_path_ecg, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            _StatCircle(label: 'Anxiety', value: anxAvg.toDouble()),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                anxAvg > 7 ? 'Your anxiety was very high' : 'Your anxiety was moderate',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                          : (audioService.isPlaying 
                              ? CupertinoIcons.pause_fill 
                              : CupertinoIcons.play_fill)
                      ),
                      label: Text(
                        isLoading 
                          ? 'Loading...' 
                          : (audioService.isPlaying 
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