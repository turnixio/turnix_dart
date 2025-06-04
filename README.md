# turnix\_dart

[![pub package](https://img.shields.io/pub/v/turnix_dart.svg)](https://pub.dev/packages/turnix_dart)
[![GitHub repo](https://img.shields.io/badge/GitHub-turnixio%2Fturnix__dart-181717?logo=github)](https://github.com/turnixio/turnix_dart)

A Dart SDK for fetching WebRTC ICE (STUN/TURN) credentials from the Turnix.io API, with
support for advanced options like regions, TTL, client IP, and per-call parameters.

---
## ⚙️ Prerequisites

- ✅ A **free account** at [https://turnix.io](https://turnix.io)
- 🔐 A **Bearer API token** from the TURNIX dashboard
---

## ✨ Features

* Fetch STUN/TURN credentials in a single call with built-in endpoint.
* Support for optional parameters: `initiatorClient`, `receiverClient`, `room`, `ttl`, `fixedRegion`, `preferredRegion`, `clientIp`.
* Automatic parsing of multiple URLs per ICE server.
* Provides `expiresAt` timestamp and real-time `timeLeft` handling for seamless credential renewal.
* Pure-Dart implementation: works in server-side Dart environments and anywhere `dart:io` is available.
* **Retrieve Available Regions**: list supported TURN regions (`slug`, `city`, `name`, status flags) via `TurnixIO.getAvailableRegions`.

## 🚀 Getting Started

### Installation

Add `turnix_dart` as a dependency in your `pubspec.yaml`:

```yaml
dependencies:
  turnix_dart: ^0.1.6
```

Then run:

```bash
dart pub get
```

### Usage

Import the package:

```dart
import 'package:turnix_dart/turnix_dart.dart';
```

Fetch credentials:

```dart
final creds = await TurnixIO.getIceCredentials(
  apiToken: 'YOUR_API_TOKEN',
  room: 'chat-room-42',
  ttl: 600,
  clientIp: '203.0.113.5',
);

// Configure your RTCPeerConnection:
final pc = await createPeerConnection({
  'iceServers': creds.iceServers.map(
    (s) => {
      'urls': s.urls,
      if (s.username != null) 'username': s.username,
      if (s.credential != null) 'credential': s.credential,
    },
  ).toList(),
});
```

### Retrieving Available Regions

Use this method to fetch all TURN regions supported by Turnix. Each `Region` includes:

* `slug`: identifier (e.g. `us-east`)
* `nat2`: country code
* `city` and `name`
* `lat`, `lon` coordinates
* `isOnline` and `isOperational` flags

```dart
// Fetch regions
final regions = await TurnixIO.getAvailableRegions(
  apiToken: 'YOUR_API_TOKEN',
);

// Print JSON-encoded list
print(
  'Available regions: ${jsonEncode(regions.map((region) => region.toString()).join(","))}',
);
```

## 🧪 Advanced Options

All parameters are optional. Pass only those you need:

| Parameter         | Type     | Description                                                                                                                                                                                           |
| ----------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `initiatorClient` | `String` | An identifier for the call initiator.                                                                                                                                                                 |
| `receiverClient`  | `String` | An identifier for the call receiver.                                                                                                                                                                  |
| `room`            | `String` | A room or session identifier to scope TURN URLs.                                                                                                                                                      |
| `ttl`             | `int`    | Time-to-live in seconds for the credentials.                                                                                                                                                          |
| `fixedRegion`     | `String` | **Strict region**: forces allocation in the specified region (e.g., `us-east-1`); if unavailable, the request will fail.                                                                              |
| `preferredRegion` | `String` | **Preferred region**: hints allocation in a region (e.g., `eu-central-1`); if unavailable, the server will fall back to another region.                                                               |
| `clientIp`        | `String` | Client IP for geofencing, sent as `X-TURN-CLIENT-IP` header. Defaults to the requester's IP address if unset, used to determine region when neither `fixedRegion` nor `preferredRegion` is specified. |

## ⏳ Handling Expiration

The `IceCredentials` object exposes:

* `iceServers`: a list of `IceServer(urls, username?, credential?)` for your `RTCPeerConnection`.
* `expiresAt`: a `DateTime` after which credentials are invalid.

Schedule refreshes by comparing `expiresAt` to `DateTime.now()`:

```dart
final now = DateTime.now();
final timeLeft = creds.expiresAt.difference(now);
if (timeLeft < Duration(seconds: 30)) {
  creds = await TurnixIO.getIceCredentials(apiToken: 'YOUR_API_TOKEN');
}
```

## 📱 Example App

See the `example/` directory for a demo script showing usage and credential parsing.

## ❤️ Contributing

Contributions and issues are welcome! Please open a PR or issue
on [GitHub](https://github.com/turnixio/turnix_dart).

## 📄 License

This package is released under the MIT License. See [LICENSE](LICENSE) for details.

---

MIT License

Copyright (c) YEAR Turnix

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
