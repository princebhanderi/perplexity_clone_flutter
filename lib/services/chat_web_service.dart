import 'dart:async';
import 'dart:convert';
import 'package:web_socket_client/web_socket_client.dart';

class ChatWebService {
  static final _instance = ChatWebService._internal();
  WebSocket? _socket;
  bool _isConnected = false;

  factory ChatWebService() => _instance;

  ChatWebService._internal();
  final _searchResultController = StreamController<Map<String, dynamic>>();
  final _contentController = StreamController<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get searchResultStream =>
      _searchResultController.stream;
  Stream<Map<String, dynamic>> get contentStream => _contentController.stream;

  void connect() {
    if (_socket != null) return;
    final socket = WebSocket(Uri.parse("ws://localhost:8000/ws/chat"));
    _socket = socket;

    // Track connection state
    socket.connection.listen((state) {
      _isConnected = state is Connected;
    });

    socket.messages.listen((message) {
      final data = json.decode(message);
      if (data['type'] == 'search_result') {
        _searchResultController.add(data);
      } else if (data['type'] == 'content') {
        _contentController.add(data);
      }
    }, onError: (_) {}, onDone: () {
      _isConnected = false;
      _socket = null;
    });
  }

  Future<void> chat(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    // Ensure connected before sending (wait up to 5s)
    final socket = _socket;
    if (socket == null) return;

    if (!_isConnected) {
      try {
        await socket.connection.firstWhere((s) => s is Connected).timeout(
          const Duration(seconds: 5),
        );
        _isConnected = true;
      } catch (_) {
        return;
      }
    }

    socket.send(json.encode({'query': trimmed}));
  }
}
