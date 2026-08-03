import 'dart:io' show Platform;
import 'package:cuid2/cuid2.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Collision-resistant Cuid2 for offline-first primary keys.
String newLocalId() => cuid();

/// Get computer Hardware Fingerprint string.
Future<String> getDeviceHardwareId() async {
  final deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.deviceId.trim();
    }
    if (Platform.isMacOS) {
      final macInfo = await deviceInfo.macOsInfo;
      final guid = macInfo.systemGUID;
      if (guid != null) return guid.trim();
    }
    if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      final machineId = linuxInfo.machineId;
      if (machineId != null) return machineId.trim();
    }
  } catch (e) {
    // Fallback if platform fails
  }
  return "UNKNOWN-HARDWARE-ID";
}

/// Coerce remote/local values to trimmed strings for Postgres text columns.
String safeIdString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString().trim();
}

/// Nullable FK: returns null when absent/blank (never an int).
String? optionalIdString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

/// Keys that must be String (or null), never int, in Supabase JSON payloads.
const syncStringIdKeys = {
  'id',
  'farmId',
  'farm_id',
  'houseId',
  'house_id',
  'batchId',
  'batch_id',
  'customerId',
  'customer_id',
  'supplierId',
  'supplier_id',
  'itemId',
  'item_id',
  'feedTypeId',
  'feed_type_id',
  'formulationId',
  'formulation_id',
  'categoryId',
  'category_id',
};

/// Throws if any known ID field is sent as int (prevents 42883 text=integer errors).
void assertSyncPayloadUsesStringIds(Map<String, dynamic> payload) {
  for (final entry in payload.entries) {
    if (!syncStringIdKeys.contains(entry.key)) continue;
    final v = entry.value;
    if (v == null) continue;
    if (v is int || v is double) {
      throw ArgumentError(
        'Sync payload key "${entry.key}" must be String, got ${v.runtimeType}',
      );
    }
    if (v is! String) {
      throw ArgumentError(
        'Sync payload key "${entry.key}" must be String, got ${v.runtimeType}',
      );
    }
  }
}
