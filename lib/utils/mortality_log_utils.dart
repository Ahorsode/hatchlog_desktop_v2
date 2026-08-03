
export 'mortality_reasons.dart' show mortalityReasons;

/// Health/mortality logging contract aligned with web `logHealthEvent`.
const String legacyIsolationCategory = 'ISOLATION';

const String isolationMortalityCategory = 'Isolation';
const String isolationMortalitySubCategory = 'Isolation Mortality';

String resolveHealthType(String? value) {
  final normalized = value?.trim().toUpperCase() ?? '';
  if (normalized == 'SICK' || normalized == 'QUARANTINE') {
    return 'SICK';
  }
  return 'DEAD';
}

bool isSickHealthType(String? value) => resolveHealthType(value) == 'SICK';

bool isDeadHealthType(String? value) => !isSickHealthType(value);

bool isLegacyIsolationRecord({String? category}) =>
    category?.trim().toUpperCase() == legacyIsolationCategory;

bool isDeadMortalityRecord({String? healthType, String? category}) {
  if (isLegacyIsolationRecord(category: category)) {
    return false;
  }
  return isDeadHealthType(healthType);
}

bool isSickMortalityRecord({String? healthType, String? category}) {
  return isSickHealthType(healthType) ||
      isLegacyIsolationRecord(category: category);
}

String resolveSubCategory({
  required String category,
  required String subCategory,
}) {
  if (category == 'Unknown') {
    return 'Unknown cause yet';
  }
  return subCategory.trim().isEmpty ? category : subCategory;
}

String? validateHealthLog({
  required int count,
  required int currentCount,
  required String healthType,
  bool requireIsolationRoom = false,
  String? isolationRoomId,
}) {
  if (count <= 0) {
    return 'Count is required.';
  }
  if (count > currentCount) {
    return 'Cannot exceed current bird count';
  }
  if (isSickHealthType(healthType) &&
      requireIsolationRoom &&
      (isolationRoomId == null || isolationRoomId.trim().isEmpty)) {
    return 'Isolation room is required.';
  }
  return null;
}

Map<String, dynamic> buildHealthLogPayload({
  required String batchId,
  required int count,
  required String healthType,
  required String category,
  required String subCategory,
  String? reason,
  String? isolationRoomId,
  required DateTime logDate,
}) {
  final resolvedType = resolveHealthType(healthType);
  return {
    'batch_id': batchId,
    'count': count,
    'health_type': resolvedType,
    'type': resolvedType,
    'category': category,
    'sub_category': resolveSubCategory(
      category: category,
      subCategory: subCategory,
    ),
    if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    if (resolvedType == 'SICK' &&
        isolationRoomId != null &&
        isolationRoomId.trim().isNotEmpty)
      'isolation_room_id': isolationRoomId,
    'log_date': logDate.toIso8601String(),
  };
}

({int currentCountDelta, int isolationCountDelta}) healthLogBatchDeltas({
  required String healthType,
  required int count,
}) {
  if (isSickHealthType(healthType)) {
    return (currentCountDelta: -count, isolationCountDelta: count);
  }
  return (currentCountDelta: -count, isolationCountDelta: 0);
}
