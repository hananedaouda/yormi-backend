import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';

class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  PusherChannelsClient? _client;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect({
    required Function(Map<String, dynamic> mission) onMissionReceived,
  }) async {
    try {
      final options = PusherChannelsOptions.fromHost(
        scheme: 'wss',
        host: 'outpour-bribe-flanking.ngrok-free.dev',
        key: 'yrrwjrtdpnhp2qwdqm7y',
        port: 443,
      );

      _client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (exception, trace, refresh) {
          _isConnected = false;
          print('Reverb connection error: $exception');
          refresh();
        },
      );

      _client!.onConnectionEstablished.listen((_) {
        _isConnected = true;
        print('Reverb connecté');
      });

      final channel = _client!.publicChannel('missions');

      channel.bind('mission.created').listen((event) {
        try {
          if (event.data != null) {
            final decoded = json.decode(event.data!);
            onMissionReceived(decoded);
          }
        } catch (e) {
          print('Erreur parsing mission: $e');
        }
      });

      await _client!.connect();
      channel.subscribe();

    } catch (e) {
      print('Erreur connexion Reverb: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      await _client?.disconnect();
      _isConnected = false;
    } catch (e) {
      print('Erreur déconnexion Reverb: $e');
    }
  }
}