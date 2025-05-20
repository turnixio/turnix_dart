library turnix_dart;

import 'dart:convert';
import 'package:http/http.dart' as http;

// Base endpoints
const _ICE_ENDPOINT = "https://turnix.io/api/v1/credentials/ice";
const _REGIONS_ENDPOINT = "https://turnix.io/api/v1/regions";

/// Represents a single ICE server entry.
class IceServer {
  /// One or more STUN/TURN URLs
  final List<String> urls;
  final String? username;
  final String? credential;

  IceServer({
    required this.urls,
    this.username,
    this.credential,
  });

  factory IceServer.fromJson(Map<String, dynamic> json) {
    final raw = json['urls'] ?? json['url'] ?? <String>[];
    final urls = raw is List ? List<String>.from(raw) : <String>[raw as String];
    return IceServer(
      urls: urls,
      username: json['username'] as String?,
      credential: json['credential'] as String?,
    );
  }
}

/// The full ICE credentials payload.
class IceCredentials {
  final List<IceServer> iceServers;
  final DateTime expiresAt;

  IceCredentials({ required this.iceServers, required this.expiresAt });

  factory IceCredentials.fromJson(Map<String, dynamic> json) {
    final servers = (json['iceServers'] as List)
        .map((s) => IceServer.fromJson(s as Map<String, dynamic>))
        .toList();
    return IceCredentials(
      iceServers: servers,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}

/// Represents a single TURN region.
class Region {
  final String slug;
  final String nat2;
  final String city;
  final String name;
  final double lat;
  final double lon;
  final bool isOnline;
  final bool isOperational;

  Region({
    required this.slug,
    required this.nat2,
    required this.city,
    required this.name,
    required this.lat,
    required this.lon,
    required this.isOnline,
    required this.isOperational,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      slug: json['slug'] as String,
      nat2: json['nat2'] as String,
      city: json['city'] as String,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      isOnline: json['is_online'] as bool,
      isOperational: json['is_operational'] as bool,
    );
  }

  @override
  String toString() {
    return 'Region(slug: $slug, nat2: $nat2, city: $city, name: $name, lat: $lat, lon: $lon, isOnline: $isOnline, isOperational: $isOperational)';
  }
}

/// Main plugin class for Turnix SDK.
class TurnixIO {
  /// Fetches ICE credentials from the Turnix backend.
  /// Optional params correspond to Turnix query args and headers.
  static Future<IceCredentials> getIceCredentials({
    required String apiToken,
    String? initiatorClient,
    String? receiverClient,
    String? room,
    int? ttl,
    String? fixedRegion,
    String? preferredRegion,
    String? clientIp,
  }) async {
    final bodyJson = <String, dynamic>{
      if (initiatorClient != null) 'initiator_client': initiatorClient,
      if (receiverClient  != null) 'receiver_client':  receiverClient,
      if (room            != null) 'room':             room,
      if (ttl             != null) 'ttl':              ttl,
      if (fixedRegion     != null) 'fixed_region':     fixedRegion,
      if (preferredRegion != null) 'preferred_region': preferredRegion,
    };

    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (clientIp != null) 'X-TURN-CLIENT-IP': clientIp,
    };

    final response = await http.post(
      Uri.parse(_ICE_ENDPOINT),
      headers: headers,
      body: json.encode(bodyJson),
    );

    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to fetch ICE credentials (${response.statusCode})',
        Uri.parse(_ICE_ENDPOINT),
      );
    }

    return IceCredentials.fromJson(json.decode(response.body));
  }

  /// Retrieves the list of available TURN regions.
  static Future<List<Region>> getAvailableRegions({
    required String apiToken,
  }) async {
    final headers = {
      'Authorization': 'Bearer $apiToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse(_REGIONS_ENDPOINT),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to fetch regions (${response.statusCode})',
        Uri.parse(_REGIONS_ENDPOINT),
      );
    }

    final List<dynamic> body = json.decode(response.body);
    return body.map((e) => Region.fromJson(e as Map<String, dynamic>)).toList();
  }
}
