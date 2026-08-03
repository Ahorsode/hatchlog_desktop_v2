import 'package:drift/drift.dart';

import '../data/local_db.dart';

import 'finance_category_labels.dart';



enum FinanceLedgerSource { ledger, expense }



class FinanceLedgerEntry {

  const FinanceLedgerEntry({

    required this.id,

    required this.type,

    required this.category,

    required this.amount,

    required this.paymentStatus,

    required this.paymentMethod,

    required this.referenceNum,

    required this.transactionDate,

    required this.description,

    required this.source,

  });



  final String id;

  final String type;

  final String category;

  final double amount;

  final String paymentStatus;

  final String paymentMethod;

  final String? referenceNum;

  final DateTime transactionDate;

  final String? description;

  final FinanceLedgerSource source;



  bool get isAutoLogged => source == FinanceLedgerSource.expense;

  bool get isOutstanding => paymentStatus.toUpperCase() != 'PAID';

}



class FinanceLedgerSummary {

  const FinanceLedgerSummary({

    required this.totalRevenue,

    required this.totalExpense,

    required this.netPosition,

    required this.outstandingCount,

  });



  final double totalRevenue;

  final double totalExpense;

  final double netPosition;

  final int outstandingCount;

}



class FinanceLedgerService {

  FinanceLedgerService(this._db);



  final AppDatabase _db;



  Future<List<FinanceLedgerEntry>> loadEntries(String farmId) async {

    final ledgerRows = await _db.customSelect(

      '''

      SELECT id, type, category, amount, payment_status, payment_method,

             reference_num, transaction_date, description

      FROM financial_transactions

      WHERE farm_id = ? AND is_deleted = 0

      ORDER BY transaction_date DESC

      ''',

      variables: [Variable<String>(farmId)],

      readsFrom: {},

    ).get();



    final expenses = await (_db.select(_db.expenses)

          ..where((t) => t.farmId.equals(farmId)))

        .get();



    final entries = <FinanceLedgerEntry>[

      ...ledgerRows.map(

        (row) => FinanceLedgerEntry(

          id: row.read<String>('id'),

          type: row.read<String>('type').toUpperCase(),

          category: row.read<String>('category'),

          amount: row.read<double>('amount'),

          paymentStatus: row.read<String>('payment_status'),

          paymentMethod: row.read<String?>('payment_method') ?? 'Operational',

          referenceNum: row.read<String?>('reference_num'),

          transactionDate: DateTime.parse(row.read<String>('transaction_date')),

          description: row.read<String?>('description'),

          source: FinanceLedgerSource.ledger,

        ),

      ),

      ...expenses.map(

        (expense) => FinanceLedgerEntry(

          id: expense.id,

          type: 'EXPENSE',

          category: expenseCategoryLabel(expense.category),

          amount: expense.amount,

          paymentStatus: 'PAID',

          paymentMethod: 'Operational',

          referenceNum: null,

          transactionDate: expense.date,

          description: expense.description,

          source: FinanceLedgerSource.expense,

        ),

      ),

    ];



    if (entries.where((entry) => entry.type == 'REVENUE').isEmpty) {

      final sales = await (_db.select(_db.sales)

            ..where((t) => t.farmId.equals(farmId)))

          .get();

      entries.addAll(

        sales.map(

          (sale) => FinanceLedgerEntry(

            id: sale.id,

            type: 'REVENUE',

            category: 'SALES',

            amount: sale.totalAmount,

            paymentStatus: 'PAID',

            paymentMethod: 'Operational',

            referenceNum: sale.id,

            transactionDate: sale.saleDate,

            description: 'Sale ${sale.id}',

            source: FinanceLedgerSource.ledger,

          ),

        ),

      );

    }



    entries.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    return entries;

  }



  Future<FinanceLedgerSummary> loadSummary(String farmId) async {

    final entries = await loadEntries(farmId);

    final revenue = entries

        .where((entry) => entry.type == 'REVENUE')

        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final expense = entries

        .where((entry) => entry.type == 'EXPENSE')

        .fold<double>(0, (sum, entry) => sum + entry.amount);

    return FinanceLedgerSummary(

      totalRevenue: revenue,

      totalExpense: expense,

      netPosition: revenue - expense,

      outstandingCount: entries.where((entry) => entry.isOutstanding).length,

    );

  }

}

