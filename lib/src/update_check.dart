/// The version-comparison policy that decides when an update is offered.
enum UpdateCriteria {
  /// Never check for updates.
  noUpdateCheck,

  /// Offer an update on any version difference, including downgrades.
  any,

  /// Offer an update only when the remote version is higher.
  anyUpgrade,

  /// Offer an update only on a major version bump.
  majorUpgrade,

  /// Offer an update on a major or minor version bump.
  minorUpgrade,
}

/// Parses a `major.minor.patch` version string into integer segments,
/// stripping any non-numeric characters; returns null for malformed versions.
List<int>? parseVersion(String version) {
  final List<String> segments = version.trim().split('.');
  if (segments.length != 3) return null;

  final List<int> result = [];
  for (final String segment in segments) {
    final String cleaned = segment.replaceAll(RegExp(r'\D'), '');
    final int? value = int.tryParse(cleaned);
    if (value == null) return null;
    result.add(value);
  }
  return result;
}

/// Whether an update from [localVersion] to [remoteVersion] should be offered
/// according to [criteria]. If either version cannot be parsed, no update is
/// reported.
bool shouldUpdate(
  UpdateCriteria criteria,
  String remoteVersion,
  String localVersion,
) {
  final List<int>? remote = parseVersion(remoteVersion);
  final List<int>? local = parseVersion(localVersion);
  if (remote == null || local == null) return false;

  final bool majorUpdate = remote[0] > local[0];
  final bool minorUpdate = remote[1] > local[1];
  final bool patchUpdate = remote[2] > local[2];

  switch (criteria) {
    case UpdateCriteria.noUpdateCheck:
      return false;
    case UpdateCriteria.any:
      return remote[0] != local[0] ||
          remote[1] != local[1] ||
          remote[2] != local[2];
    case UpdateCriteria.anyUpgrade:
      return majorUpdate || minorUpdate || patchUpdate;
    case UpdateCriteria.majorUpgrade:
      return majorUpdate;
    case UpdateCriteria.minorUpgrade:
      return majorUpdate || minorUpdate;
  }
}