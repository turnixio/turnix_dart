# Changelog

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](https://semver.org/).

## \[0.1.7] - 2025-06-04

### Added

* Support for retrieving available TURN regions via `TurnixIO.getAvailableRegions` method, including the `Region` model with a custom `toString` method and example usage in README.

## \[0.1.5] - 2025-05-20

### Changed

* Renamed `apiKey` parameter to `apiToken` across all methods and documentation for consistency across platforms and better clarity.

## \[0.1.0] - 2025-05-19

### Added

* **Advanced Options**: support for `initiatorClient`, `receiverClient`, `room`, `ttl`, `fixedRegion`, `preferredRegion`, and `clientIp` parameters in fetch call.
* **clientIp default**: if unset, the server will use the requester's IP to determine region when neither `fixedRegion` nor `preferredRegion` is specified.
* **Error semantics**: `fixedRegion` now raises an error if allocation in the specified region is unavailable; `preferredRegion` falls back to closest available.
* **Dart extension**: added `IceCredentialsX` extension with `timeLeft` and `isExpired` convenience getters.
* **Example app update**: UI now includes:

  * “Refresh” button in the AppBar.
  * Real-time countdown of credentials’ TTL.
  * `ExpansionTile` panel for advanced options input.
* **README improvements**: clarified installation, usage, and license sections; added badges and metadata.

## \[0.0.1] - 2025-05-01

### Added

* Initial release: basic `TurnixIO.getIceCredentials` method.
* Models for `IceServer` and `IceCredentials` with JSON serialization.
* Hard-coded endpoint `https://turnix.io/api/v1/credentials/ice`.
* Basic example usage (fetch + parse ICE servers and `expiresAt`).
