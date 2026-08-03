class FinanceMonthlyPoint {
  const FinanceMonthlyPoint({
    required this.label,
    required this.revenue,
    required this.initial,
    required this.operating,
    required this.consumption,
    required this.general,
    required this.expenses,
    required this.profit,
  });

  final String label;
  final double revenue;
  final double initial;
  final double operating;
  final double consumption;
  final double general;
  final double expenses;
  final double profit;
}

class FinanceSummaryPoint {
  const FinanceSummaryPoint({
    required this.label,
    required this.key,
    required this.amount,
  });

  final String label;
  final String key;
  final double amount;
}

class ExpenseBreakdownItem {
  const ExpenseBreakdownItem({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.kind,
    this.percentage,
  });

  final String id;
  final DateTime date;
  final String category;
  final String description;
  final double amount;
  final String kind;
  final double? percentage;
}

class RevenueBreakdownItem {
  const RevenueBreakdownItem({
    required this.id,
    required this.date,
    required this.description,
    required this.amount,
    this.quantity,
    required this.kind,
    this.percentage,
  });

  final String id;
  final DateTime date;
  final String description;
  final double amount;
  final int? quantity;
  final String kind;
  final double? percentage;
}

class BatchFinanceResult {
  const BatchFinanceResult({
    required this.initialInvestment,
    required this.directExpenseTotal,
    required this.allocatedExpenseTotal,
    required this.generalPoolTotal,
    required this.generalAllocatedTotal,
    required this.consumptionAllocatedTotal,
    required this.operatingExpenses,
    required this.totalExpenses,
    required this.totalRevenue,
    required this.netProfit,
    required this.headcountSharePct,
    required this.financeMonthly,
    required this.financeSummary,
    required this.expenseBreakdown,
    required this.revenueBreakdown,
  });

  final double initialInvestment;
  final double directExpenseTotal;
  final double allocatedExpenseTotal;
  final double generalPoolTotal;
  final double generalAllocatedTotal;
  final double consumptionAllocatedTotal;
  final double operatingExpenses;
  final double totalExpenses;
  final double totalRevenue;
  final double netProfit;
  final double headcountSharePct;
  final List<FinanceMonthlyPoint> financeMonthly;
  final List<FinanceSummaryPoint> financeSummary;
  final List<ExpenseBreakdownItem> expenseBreakdown;
  final List<RevenueBreakdownItem> revenueBreakdown;
}

class BatchRevenueItem {
  const BatchRevenueItem({
    required this.id,
    required this.description,
    required this.totalPrice,
    required this.orderDate,
    this.orderStatus,
    this.quantity,
    this.unitPrice,
    required this.kind,
    this.percentage,
  });

  final String id;
  final String description;
  final double totalPrice;
  final DateTime orderDate;
  final String? orderStatus;
  final int? quantity;
  final double? unitPrice;
  final String kind;
  final double? percentage;
}

class HeadcountBatch {
  const HeadcountBatch({required this.id, required this.currentCount});

  final String id;
  final int currentCount;
}

class BatchDeepDiveHouse {
  const BatchDeepDiveHouse({required this.id, required this.name});

  final String id;
  final String name;
}

class BatchDeepDiveBatch {
  const BatchDeepDiveBatch({
    required this.id,
    required this.batchName,
    required this.breedType,
    required this.type,
    required this.status,
    required this.arrivalDate,
    required this.initialCount,
    required this.currentCount,
    required this.isolationCount,
    this.house,
    required this.initialActualCost,
    this.growthTarget,
  });

  final String id;
  final String batchName;
  final String? breedType;
  final String type;
  final String status;
  final DateTime arrivalDate;
  final int initialCount;
  final int currentCount;
  final int isolationCount;
  final BatchDeepDiveHouse? house;
  final double initialActualCost;
  final String? growthTarget;
}

class BatchDeepDiveMetrics {
  const BatchDeepDiveMetrics({
    required this.ageInDays,
    required this.totalFeed,
    required this.totalEggs,
    required this.totalMortality,
    required this.mortalityRate,
    required this.latestWeight,
    required this.fcr,
    required this.isLayer,
  });

  final int ageInDays;
  final double totalFeed;
  final int totalEggs;
  final int totalMortality;
  final double mortalityRate;
  final double latestWeight;
  final double fcr;
  final bool isLayer;
}

class BatchDeepDiveFinance {
  const BatchDeepDiveFinance({
    required this.canViewFinance,
    required this.canEditFinance,
    required this.result,
  });

  final bool canViewFinance;
  final bool canEditFinance;
  final BatchFinanceResult? result;
}

class DailyEggPoint {
  const DailyEggPoint({required this.label, required this.eggs});

  final String label;
  final int eggs;
}

class DailyMortalityPoint {
  const DailyMortalityPoint({
    required this.label,
    required this.deaths,
    required this.rate,
  });

  final String label;
  final int deaths;
  final double rate;
}

class DailySalesPoint {
  const DailySalesPoint({
    required this.label,
    required this.revenue,
    required this.units,
  });

  final String label;
  final double revenue;
  final int units;
}

class BatchDeepDiveSeries {
  const BatchDeepDiveSeries({
    required this.eggDaily,
    required this.mortalityDaily,
    required this.salesDaily,
  });

  final List<DailyEggPoint> eggDaily;
  final List<DailyMortalityPoint> mortalityDaily;
  final List<DailySalesPoint> salesDaily;
}

class FeedInventoryOption {
  const FeedInventoryOption({
    required this.id,
    required this.itemName,
    required this.stockLevel,
    required this.unit,
  });

  final String id;
  final String itemName;
  final double stockLevel;
  final String unit;
}

class AllocationBatchOption {
  const AllocationBatchOption({
    required this.id,
    required this.name,
    required this.currentCount,
  });

  final String id;
  final String name;
  final int currentCount;
}

class HealthInventoryOption {
  const HealthInventoryOption({
    required this.id,
    required this.itemName,
    required this.stockLevel,
    required this.unit,
  });

  final String id;
  final String itemName;
  final double stockLevel;
  final String unit;
}

class BatchDeepDiveForms {
  const BatchDeepDiveForms({
    required this.canEditHealth,
    required this.feedInventory,
    required this.vaccineInventory,
    required this.medicineInventory,
    required this.allocationBatches,
  });

  final bool canEditHealth;
  final List<FeedInventoryOption> feedInventory;
  final List<HealthInventoryOption> vaccineInventory;
  final List<HealthInventoryOption> medicineInventory;
  final List<AllocationBatchOption> allocationBatches;
}

class BatchDeepDivePayload {
  const BatchDeepDivePayload({
    required this.batch,
    required this.metrics,
    required this.finance,
    required this.series,
    required this.forms,
    required this.logs,
  });

  final BatchDeepDiveBatch batch;
  final BatchDeepDiveMetrics metrics;
  final BatchDeepDiveFinance finance;
  final BatchDeepDiveSeries series;
  final BatchDeepDiveForms forms;
  final BatchDeepDiveLogs logs;
}

class BatchDeepDiveLogs {
  const BatchDeepDiveLogs({
    required this.weightRecords,
    required this.feedingLogs,
    required this.eggProduction,
    required this.mortalityRecords,
    required this.vaccinations,
    required this.medications,
    required this.salesRecords,
  });

  final List<Map<String, dynamic>> weightRecords;
  final List<Map<String, dynamic>> feedingLogs;
  final List<Map<String, dynamic>> eggProduction;
  final List<Map<String, dynamic>> mortalityRecords;
  final List<Map<String, dynamic>> vaccinations;
  final List<Map<String, dynamic>> medications;
  final List<Map<String, dynamic>> salesRecords;
}
