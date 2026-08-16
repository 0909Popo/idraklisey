import 'dart:convert';

import 'package:http/http.dart' as http;

/// Retrieves a short-lived RTC token from the school's server.
///
/// The Agora certificate must only ever be configured on that server.
class AgoraTokenService {
  static const _tokenEndpoint = String.fromEnvironment(
    'AGORA_TOKEN_ENDPOINT',
    defaultValue: 'https://idrak-agora-token.ramizmehdi9.workers.dev',
  );

  Future<String> getToken({
    required String roomId,
    required String channelName,
    required int uid,
  }) async {
    final response = await http
        .post(
          Uri.parse(_tokenEndpoint),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'roomId': roomId,
            'channelName': channelName,
            'uid': uid,
          }),
        )
        // Mobile networks may need a little longer to establish the first TLS
        // connection to the token Worker. Joining Agora itself is handled
        // separately, so do not turn a slow request into a false room error.
        .timeout(const Duration(seconds: 30));

    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 || body['token'] is! String) {
      throw StateError(
        body['error']?.toString() ?? 'Ses bağlantı anahtarı alınamadı.',
      );
    }
    return body['token'] as String;
  }
}
