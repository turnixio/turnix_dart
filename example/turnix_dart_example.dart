import 'dart:convert';

import 'package:turnix_dart/turnix_dart.dart';

void main() async {
  const apiToken = 'REPLACE_WITH_YOUR_TOKEN'; // <- get on turnix.io

  try {
    final creds = await TurnixIO.getIceCredentials(
      apiToken: apiToken,
      initiatorClient: 'alice',
      receiverClient: 'bob',
      room: 'demo-room',
      ttl: 120, // optional
    );

    print('ICE credentials fetched successfully!');
    for (final server in creds.iceServers) {
      print('Server: ${server.urls.join(", ")}');
      if (server.username != null) {
        print('Username: ${server.username}');
        print('Credential: ${server.credential}');
      }
    }
    print('Expires at: ${creds.expiresAt.toIso8601String()}');

    List<Region> regions = await TurnixIO.getAvailableRegions(
      apiToken: apiToken,
    );

    print(
      'Available regions: ${jsonEncode(regions.map((region) => region.toString()).join(","))}',
    );
  } catch (e) {
    print('Error fetching ICE credentials: $e');
  }
}
