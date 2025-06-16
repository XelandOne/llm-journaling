// Copyright (c) 2024 LLM Journal. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../schemes/chat_response.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import '../components/bottom_sheet.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A screen that allows users to chat with the AI assistant about their life events
/// and receive emotional analysis and event suggestions.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

/// The state for the ChatScreen widget.
/// 
/// Manages the chat history, loading states, and user input for the chat interface.
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatResponse> _chatHistory = [];
  bool _loading = false;
  String? _error;

  /// Sends the current chat message to the API and updates the UI accordingly.
  /// 
  /// Handles loading states and error conditions while communicating with the backend.
  Future<void> _sendChat() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _apiService.submitChat(text);
      setState(() {
        _chatHistory.insert(0, response);
        _loading = false;
        _controller.clear();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 48.0, bottom: 16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Let's chat ...",
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Image.asset('lib/assets/icon.png', width: 32, height: 32),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(thickness: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.07),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: SvgPicture.asset(
                  'lib/assets/smooth_spectral_animation.svg',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('What\'s going on in your life?', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your thoughts...'
                              ,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        ),
                        minLines: 1,
                        maxLines: 3,
                        enabled: !_loading,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendChat(),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Material(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _loading ? null : _sendChat,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _loading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(CupertinoIcons.paperplane_fill, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            if (_chatHistory.isNotEmpty && _chatHistory.first.response != null) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _chatHistory.first.response!,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 17),
                  ),
                ),
              ),
            ],
            if (_chatHistory.isNotEmpty && _chatHistory.first.feeling != null && _chatHistory.first.feeling!.isNotEmpty) ...[
              ..._chatHistory.first.feeling!.map((feeling) => Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
                color: Colors.yellow.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(CupertinoIcons.smiley, color: Colors.orange.shade400, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Feeling detected:',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              feeling.feelings.join(", "),
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score:  0${feeling.score}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            if (feeling.datetime != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Time: ${feeling.datetime}',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
              const SizedBox(height: 12),
            ],
            if (_chatHistory.isNotEmpty && _chatHistory.first.createdEvents != null && _chatHistory.first.createdEvents!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 2, bottom: 4),
                child: Text('Created Events', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              Divider(thickness: 1, color: Colors.grey.shade100),
              const SizedBox(height: 6),
              Column(
                children: _chatHistory.first.createdEvents!.map((event) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(CupertinoIcons.calendar, color: theme.colorScheme.primary),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${_formatTime(event.startTime)}\n",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: event.description,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.description,
                          style: theme.textTheme.bodyLarge,
                          softWrap: true,
                        ),
                      ],
                    ),
                    subtitle: const Text('→ click for details'),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        isScrollControlled: true,
                        builder: (context) => EventBottomSheet(event: event),
                      );
                    },
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
} 