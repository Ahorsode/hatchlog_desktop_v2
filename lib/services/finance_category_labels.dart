const expenseCategoryLabels = <String, String>{
  'FEED': 'Feed Purchases',
  'MEDICATION': 'Flock Vaccines & Medication',
  'EQUIPMENT': 'Equipment & Maintenance',
  'UTILITIES': 'Utilities',
  'SALARY': 'Labor & Salaries',
  'MAINTENANCE': 'Equipment & Maintenance',
  'OTHER': 'Other OpEx',
  'LIVESTOCK_PURCHASE': 'Day-Old Chicks Purchase',
  'TRANSPORT': 'Transport',
};

const revenueCategories = [
  'Egg Wholesale Revenue',
  'Broiler Sales',
  'Manure Sales',
  'Other Revenue',
];

const expenseEnumCategories = [
  'FEED',
  'MEDICATION',
  'LIVESTOCK_PURCHASE',
  'SALARY',
  'UTILITIES',
  'TRANSPORT',
  'EQUIPMENT',
  'MAINTENANCE',
  'OTHER',
];

const paymentMethods = [
  'Cash',
  'Mobile Money',
  'Bank Transfer',
  'Card',
];

String expenseCategoryLabel(String? raw) {
  final key = raw?.trim().toUpperCase() ?? '';
  return expenseCategoryLabels[key] ?? raw?.trim() ?? 'Other OpEx';
}

String expenseEnumFromLabel(String label) {
  for (final entry in expenseCategoryLabels.entries) {
    if (entry.value == label) {
      return entry.key;
    }
  }
  return 'OTHER';
}
