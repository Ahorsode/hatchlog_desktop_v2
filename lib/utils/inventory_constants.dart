/// Cloud inventory.category for feed / ingredient stock.
const String kFeedInventoryCategory = 'FEED';

const String kDefaultFeedUnit = 'bags';

const String kMedicineInventoryCategory = 'MEDICINE';

const String kVaccineInventoryCategory = 'VACCINE';

const String kOtherInventoryCategory = 'OTHER';

const List<String> kInventoryFormCategories = [
  kFeedInventoryCategory,
  kMedicineInventoryCategory,
  kVaccineInventoryCategory,
  kOtherInventoryCategory,
];

const List<String> kHealthInventoryFormCategories = [
  kMedicineInventoryCategory,
  kVaccineInventoryCategory,
];

/// Optional category filter on the inventory list (null = all).
const String? kInventoryCategoryFilterAll = null;

String defaultUnitForInventoryCategory(String category) {
  switch (category.toUpperCase()) {
    case kFeedInventoryCategory:
      return kDefaultFeedUnit;
    case kVaccineInventoryCategory:
      return 'doses';
    default:
      return 'units';
  }
}

double normalizeHealthInventoryStock({
  required String category,
  required String? usageType,
  required double stockLevel,
}) {
  if (kHealthInventoryFormCategories.contains(category.toUpperCase()) &&
      (usageType?.toUpperCase() ?? '') == 'ONE_TIME') {
    return 1;
  }
  return stockLevel;
}

bool matchesInventoryCategoryFilter(String? itemCategory, String? filter) {
  if (filter == null || filter.isEmpty) {
    return true;
  }
  final normalized = itemCategory?.toUpperCase() ?? kOtherInventoryCategory;
  if (filter == kOtherInventoryCategory) {
    return !kInventoryFormCategories.contains(normalized) ||
        normalized == kOtherInventoryCategory;
  }
  return normalized == filter.toUpperCase();
}
