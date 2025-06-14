import 'package:flutter/material.dart';
import 'api_service.dart';
import 'chat_response.dart';

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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's chat about", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          Center(
            child: Icon(Icons.bubble_chart, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
          ),
          const SizedBox(height: 32),
          Text('Chat', style: Theme.of(context).textTheme.titleMedium),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '... type in your thoughts',
                    border: OutlineInputBorder(),
                  ),
                  minLines: 1,
                  maxLines: 3,
                  enabled: !_loading,
                  onSubmitted: (_) => _sendChat(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                onPressed: _loading ? null : _sendChat,
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 32),
          Text('Detecting Log', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Expanded(
            child: _chatHistory.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('- Feeling detected'),
                      Text('- Event detected'),
                    ],
                  )
                : ListView.builder(
                    itemCount: _chatHistory.length,
                    itemBuilder: (context, index) {
                      final resp = _chatHistory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (resp.feeling != null)
                              Text('- Feeling detected: \\${resp.feeling!.feelings.join(", ")} (score: \\${resp.feeling!.score})'),
                            if (resp.event != null)
                              Text('- Event detected: \\${resp.event!.description}'),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 