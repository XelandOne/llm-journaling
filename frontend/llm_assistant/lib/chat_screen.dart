import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'chat_response.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'bottom_sheet.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  final List<ChatResponse> _chatHistory = [];
  bool _loading = false;
  String? _error;

  void _sendChat() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await apiService.submitChat(text);
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0, bottom: 20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Let's chat about", style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Center(
              child: Icon(CupertinoIcons.chat_bubble_2_fill, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            Text('Chat', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: '... type in your thoughts',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        ),
                        minLines: 1,
                        maxLines: 3,
                        enabled: !_loading,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendChat(),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: _loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(CupertinoIcons.paperplane_fill),
                      onPressed: _loading ? null : _sendChat,
                    ),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            const SizedBox(height: 8),
            if (_chatHistory.isNotEmpty && _chatHistory.first.response != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_chatHistory.first.response!),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_chatHistory.isNotEmpty && _chatHistory.first.createdEvents != null && _chatHistory.first.createdEvents!.isNotEmpty) ...[
              Text('Created Events', style: Theme.of(context).textTheme.titleMedium),
              Divider(thickness: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),
              Column(
                children: _chatHistory.first.createdEvents!.map((event) => Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(CupertinoIcons.calendar, color: Theme.of(context).colorScheme.primary),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatTime(event.startTime),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
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
                    subtitle: const Text('→ click for details'),
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
                )).toList(),
              ),
              const SizedBox(height: 32),
            ],
            _chatHistory.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _chatHistory.map((resp) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (resp.feeling != null)
                            Text('- Feeling detected: ${resp.feeling!.feelings.join(", ")} (score: ${resp.feeling!.score})'),
                          if (resp.event != null)
                            Text('- Event detected: ${resp.event!.description}'),
                        ],
                      ),
                    )).toList(),
                  ),
          ],
        ),
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