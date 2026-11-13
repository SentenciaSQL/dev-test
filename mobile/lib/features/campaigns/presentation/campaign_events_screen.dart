import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/storage/token_storage.dart';

/// Live campaign progress via SSE (`GET /campaigns/{id}/events`).
class CampaignEventsScreen extends ConsumerStatefulWidget {
  const CampaignEventsScreen({
    super.key,
    required this.campaignId,
    required this.campaignName,
  });

  final String campaignId;
  final String campaignName;

  @override
  ConsumerState<CampaignEventsScreen> createState() =>
      _CampaignEventsScreenState();
}

class _CampaignEventsScreenState extends ConsumerState<CampaignEventsScreen> {
  final _events = <String>[];
  HttpClient? _client;
  var _connected = false;
  String? _error;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    setState(() {
      _error = null;
      _connected = false;
    });
    try {
      final token =
          await ref.read(tokenStorageProvider).readAccessToken() ?? '';
      final uri = Uri.parse(
        '${AppConfig.apiBaseUrl}/campaigns/${widget.campaignId}/events',
      );
      final client = HttpClient();
      _client = client;
      final request = await client.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      if (token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      final response = await request.close();
      if (response.statusCode != 200) {
        setState(() {
          _error = 'HTTP ${response.statusCode}';
          _connected = false;
        });
        return;
      }
      setState(() => _connected = true);
      final lines = response
          .transform(utf8.decoder)
          .transform(const LineSplitter());
      _sub = lines.listen(
        (line) {
          if (line.isEmpty) return;
          setState(() {
            _events.insert(0, line);
            if (_events.length > 80) _events.removeLast();
          });
        },
        onError: (Object e) {
          if (mounted) {
            setState(() {
              _error = e.toString();
              _connected = false;
            });
          }
        },
        onDone: () {
          if (mounted) setState(() => _connected = false);
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _connected = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _client?.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SSE · ${widget.campaignName}'),
        actions: [
          IconButton(
            tooltip: 'Reconectar',
            onPressed: () async {
              await _sub?.cancel();
              _client?.close(force: true);
              _events.clear();
              await _connect();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error != null
                  ? 'Error: $_error'
                  : _connected
                      ? 'Conectado a eventos en vivo'
                      : 'Conectando…',
            ),
          ),
          Expanded(
            child: _events.isEmpty
                ? const Center(child: Text('Esperando eventos…'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _events.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        Text(_events[index], style: const TextStyle(fontFamily: 'monospace')),
                  ),
          ),
        ],
      ),
    );
  }
}
