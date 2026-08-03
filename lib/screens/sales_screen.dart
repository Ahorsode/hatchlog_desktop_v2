import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' hide Column, Batch;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/local_db.dart';
import '../data/sync_engine.dart';
import '../services/auth_service.dart';
import '../utils/farm_utils.dart';
import '../utils/id_utils.dart';
import '../utils/user_role.dart';
import '../utils/inventory_sale_utils.dart';
import '../widgets/sale_entry_dialog.dart';
import 'sales_analytics_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late AppDatabase db;
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _cashReceivedController = TextEditingController();
  final _discountController = TextEditingController();
  final _noteController = TextEditingController();
  final _customerPhoneController = TextEditingController();

  final _quantityFocus = FocusNode();
  final _unitPriceFocus = FocusNode();
  final _cashReceivedFocus = FocusNode();
  final _discountFocus = FocusNode();
  final _noteFocus = FocusNode();

  bool _isWorkerRole = true;
  bool _isSavingSale = false;
  bool _isWalkInSale = false;
  String _paymentMethod = 'Cash';
  String? _selectedCustomerId;
  String? _selectedBatchId;
  String? _lastSavedInvoicePath;
  DateTime _saleDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    db = Provider.of<AppDatabase>(context, listen: false);
    final normalizedRole = UserRoleUtils.normalize(
      UserSession().currentWorkerRole,
    );
    _isWorkerRole = normalizedRole == UserRoleUtils.operational;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    _cashReceivedController.dispose();
    _discountController.dispose();
    _noteController.dispose();
    _customerPhoneController.dispose();
    _quantityFocus.dispose();
    _unitPriceFocus.dispose();
    _cashReceivedFocus.dispose();
    _discountFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _onQuantitySubmitted() {
    FocusScope.of(context).requestFocus(_cashReceivedFocus);
  }

  void _onCashReceivedSubmitted() {
    if (_isWorkerRole) {
      FocusScope.of(context).requestFocus(_noteFocus);
    } else {
      FocusScope.of(context).requestFocus(_unitPriceFocus);
    }
  }

  int _currentQuantity() => int.tryParse(_quantityController.text.trim()) ?? 0;

  double _currentUnitPrice() =>
      double.tryParse(_unitPriceController.text.trim()) ?? 0.0;

  double _currentCashReceived() =>
      double.tryParse(_cashReceivedController.text.trim()) ?? 0.0;

  double _currentDiscount() =>
      double.tryParse(_discountController.text.trim()) ?? 0.0;

  double _computeNetAmount() {
    final quantity = _currentQuantity();
    if (quantity <= 0) return 0.0;
    final cash = _currentCashReceived();
    if (_isWorkerRole) {
      return cash;
    }
    final unitPrice = _currentUnitPrice();
    final discount = _currentDiscount();
    return (quantity * unitPrice) - discount;
  }

  Future<void> _submitSalesWorkstationEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = _currentQuantity();
    final cashReceived = _currentCashReceived();
    final netAmount = _computeNetAmount();
    if (quantity <= 0 || netAmount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a valid quantity and payment amount.'),
          ),
        );
      }
      return;
    }

    final batchId = _selectedBatchId;
    final customerId = _selectedCustomerId;
    if (batchId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch selection is required.')),
        );
      }
      return;
    }
    if (!_isWalkInSale && customerId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer selection is required for regular sales.'),
          ),
        );
      }
      return;
    }

    setState(() => _isSavingSale = true);
    final syncEngine = context.read<SyncEngine>();
    try {
      final farmId = await _getFarmId();
      final workerId = await FarmUtils.getRequiredUserId();
      if (farmId == null) throw Exception('Farm is not bound to this device.');

      final unitPrice = _isWorkerRole
          ? (quantity == 0 ? 0.0 : cashReceived / quantity)
          : _currentUnitPrice();
      final now = DateTime.now().toUtc();
      final saleDate = _saleDate.toUtc();

      await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              id: newLocalId(),
              farmId: farmId,
              batchId: Value(batchId),
              customerId: Value(customerId),
              quantity: quantity,
              unitPrice: unitPrice,
              totalAmount: netAmount,
              saleDate: Value(saleDate),
              userId: Value(workerId),
              synced: const Value(false),
            ),
          );

      if (customerId != null) {
        final customer = await (db.select(
          db.customers,
        )..where((t) => t.id.equals(customerId))).getSingleOrNull();
        if (customer != null) {
          await (db.update(
            db.customers,
          )..where((t) => t.id.equals(customerId))).write(
            CustomersCompanion(
              balanceOwed: Value(customer.balanceOwed + netAmount),
              synced: const Value(false),
              updatedAt: Value(now),
            ),
          );
        }
      }

      _clearSalesForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale recorded to the desktop sales workstation.'),
          ),
        );
      }
      syncEngine.syncNow();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to record sale: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSavingSale = false);
    }
  }

  void _clearSalesForm() {
    _quantityController.clear();
    _unitPriceController.clear();
    _cashReceivedController.clear();
    _discountController.clear();
    _noteController.clear();
    _customerPhoneController.clear();
    _saleDate = DateTime.now();
  }

  Future<void> _pickSaleDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_saleDate),
    );
    if (time == null || !mounted) return;

    setState(() {
      _saleDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _generateInvoiceAndSave() async {
    final invoiceNumber = _formatInvoiceNumber();
    final quantity = _currentQuantity();
    final netAmount = _computeNetAmount();
    final cashReceived = _currentCashReceived();
    final customerPhone = _customerPhoneController.text.trim();
    final customerName = _selectedCustomerId ?? 'Guest';
    final batchLabel = _selectedBatchId ?? 'Egg sales';
    final paymentMethod = _paymentMethod;
    final note = _noteController.text.trim();

    if (quantity <= 0 || netAmount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter sale details before generating invoice.'),
          ),
        );
      }
      return;
    }

    try {
      final folderPath = await _resolveInvoiceDirectory();
      final fileName = 'HatchLog_Invoice_$invoiceNumber.pdf';
      final file = File(p.join(folderPath, fileName));
      final document = pw.Document();
      final now = DateTime.now();

      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Opacity(
                    opacity: 0.08,
                    child: pw.Center(
                      child: pw.Text(
                        'PAID',
                        style: pw.TextStyle(
                          fontSize: 120,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.red300,
                        ),
                      ),
                    ),
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'HatchLog Agro ERP',
                              style: pw.TextStyle(
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 6),
                            pw.Text('Invoice generated by HatchLog Desktop'),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Invoice #$invoiceNumber',
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(now)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      padding: const pw.EdgeInsets.all(16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bill To:',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(customerName),
                          if (customerPhone.isNotEmpty) pw.Text(customerPhone),
                          pw.SizedBox(height: 12),
                          pw.Text(
                            'Payment Method: $paymentMethod',
                            style: pw.TextStyle(fontSize: 11),
                          ),
                          if (note.isNotEmpty)
                            pw.Text(
                              'Note: $note',
                              style: pw.TextStyle(fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.TableHelper.fromTextArray(
                      headers: ['Item', 'Qty', 'Unit', 'Discount', 'Total'],
                      data: [
                        [
                          batchLabel,
                          quantity.toString(),
                          _isWorkerRole
                              ? 'Auto'
                              : _currentUnitPrice().toStringAsFixed(2),
                          _isWorkerRole
                              ? '0.00'
                              : _currentDiscount().toStringAsFixed(2),
                          netAmount.toStringAsFixed(2),
                        ],
                      ],
                      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      cellAlignment: pw.Alignment.centerLeft,
                      cellStyle: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Subtotal: ₵${netAmount.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                            pw.Text(
                              'Total Paid: ₵${cashReceived.toStringAsFixed(2)}',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Thank you for trusting HatchLog.',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

      await file.writeAsBytes(await document.save());
      setState(() => _lastSavedInvoicePath = file.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invoice saved at ${file.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unable to save invoice: $e')));
      }
    }
  }

  Future<String> _resolveInvoiceDirectory() async {
    final defaultDir = await getApplicationDocumentsDirectory();
    final fallback = Directory(p.join(defaultDir.path, 'HatchLog', 'Invoices'));
    try {
      final selected = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose HatchLog invoice folder',
      );
      final directory = selected != null ? Directory(selected) : fallback;
      await directory.create(recursive: true);
      return directory.path;
    } catch (_) {
      await fallback.create(recursive: true);
      return fallback.path;
    }
  }

  String _formatInvoiceNumber() {
    final seconds = DateTime.now().millisecondsSinceEpoch;
    return 'HL-${seconds.toString().substring(seconds.toString().length - 8)}';
  }

  Future<void> _sendInvoiceToWhatsApp() async {
    final phone = _customerPhoneController.text.trim();
    if (phone.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter the customer phone number first.'),
          ),
        );
      }
      return;
    }

    final pathText = _lastSavedInvoicePath != null
        ? '\nInvoice path: $_lastSavedInvoicePath'
        : '';
    final uri = Uri.parse(
      'https://wa.me/${phone.replaceAll(RegExp(r'[^0-9]'), '')}?text=${Uri.encodeComponent('Your HatchLog invoice is ready. Please see the attached file path below:$pathText')}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open WhatsApp.')));
    }
  }

  Future<String?> _getFarmId() async => FarmUtils.getBoundFarmId();

  Future<void> _showMultiLineSaleDialog(
    List<Customer> customers,
    List<Batch> batches,
  ) async {
    final inventory = await (db.select(db.inventory)).get();
    if (!mounted) return;
    final saved = await showSaleEntryDialog(
      context: context,
      db: db,
      customers: customers,
      batches: batches,
      inventory: inventory,
      canOverridePrices: !_isWorkerRole,
    );
    if (saved == true && mounted) {
      context.read<SyncEngine>().syncNow();
      setState(() {});
    }
  }

  Future<void> _showSettleDialog(Customer customer) async {
    final balance = customer.balanceOwed;
    final paymentCtrl = TextEditingController();
    double amountToPay = 0.0;
    final formKey = GlobalKey<FormState>();
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.orange,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Settle Balance',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current Balance: ${currency.format(balance)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'PAYMENT AMOUNT',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: paymentCtrl,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                    decoration: InputDecoration(
                      prefixText: 'GH₵ ',
                      hintText: '0.00',
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.auto_fix_high_rounded,
                          color: Colors.orange,
                        ),
                        tooltip: 'Pay Full Amount',
                        onPressed: () {
                          paymentCtrl.text = balance.toStringAsFixed(2);
                          setDlgState(() => amountToPay = balance);
                        },
                      ),
                    ),
                    onChanged: (v) {
                      setDlgState(
                        () => amountToPay = double.tryParse(v) ?? 0.0,
                      );
                    },
                    validator: (v) {
                      final val = double.tryParse(v ?? '') ?? 0.0;
                      if (val <= 0) return 'Enter a valid amount';
                      if (val > balance + 0.01) {
                        return 'Cannot pay more than balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Live math preview
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        _dialogMathRow(
                          'Original Balance',
                          currency.format(balance),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        _dialogMathRow(
                          'Payment Amount',
                          '- ${currency.format(amountToPay)}',
                          isNegative: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1, thickness: 2),
                        ),
                        _dialogMathRow(
                          'New Balance',
                          currency.format(balance - amountToPay),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final newBalance = balance - amountToPay;
                final syncEngine = Provider.of<SyncEngine>(
                  context,
                  listen: false,
                );

                await (db.update(
                  db.customers,
                )..where((t) => t.id.equals(customer.id))).write(
                  CustomersCompanion(
                    balanceOwed: Value(newBalance < 0.01 ? 0.0 : newBalance),
                    synced: const Value(false),
                    updatedAt: Value(DateTime.now()),
                  ),
                );

                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
                syncEngine.syncNow();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'CONFIRM PAYMENT',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogMathRow(
    String label,
    String value, {
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isNegative
                ? Colors.redAccent
                : (isBold
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant),
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            fontSize: isBold ? 15 : 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'GH₵ ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isNarrow = constraints.maxWidth < 850;

          return Padding(
            padding: EdgeInsets.all(isNarrow ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                StreamBuilder<List<Customer>>(
                  stream: (db.select(
                    db.customers,
                  )..where((t) => t.customerType.equals('CUSTOMER'))).watch(),
                  builder: (context, custSnap) {
                    return StreamBuilder<List<Batch>>(
                      stream: db.select(db.batches).watch(),
                      builder: (context, batchSnap) {
                        final customers = custSnap.data ?? [];
                        final batches = batchSnap.data ?? [];

                        if (isNarrow) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sales Management',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SalesAnalyticsScreen(),
                                    ),
                                  ),
                                  icon: const Icon(Icons.analytics_rounded),
                                  label: const Text('Analytics'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: customers.isEmpty
                                      ? null
                                      : () => _showMultiLineSaleDialog(
                                          customers,
                                          batches,
                                        ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Record Sale'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sales Management',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'Track transactions and outstanding balances',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SalesAnalyticsScreen(),
                                    ),
                                  ),
                                  icon: const Icon(Icons.analytics_rounded),
                                  label: const Text('Analytics'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: customers.isEmpty
                                      ? null
                                      : () => _showMultiLineSaleDialog(
                                          customers,
                                          batches,
                                        ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Record Sale'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 28),

                FocusTraversalGroup(
                  policy: WidgetOrderTraversalPolicy(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Desktop Sales Workstation',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'High-speed HatchLog egg sales entry with keyboard-first navigation and audit-safe product controls.',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  CheckboxListTile(
                                    title: const Text(
                                      'Walk-in / One-time customer',
                                    ),
                                    subtitle: const Text(
                                      'Record this sale without linking to a saved customer.',
                                    ),
                                    value: _isWalkInSale,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: (value) {
                                      setState(() {
                                        _isWalkInSale = value == true;
                                        if (_isWalkInSale) {
                                          _selectedCustomerId = null;
                                        }
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  StreamBuilder<List<Customer>>(
                                    stream:
                                        (db.select(db.customers)..where(
                                              (t) => t.customerType.equals(
                                                'CUSTOMER',
                                              ),
                                            ))
                                            .watch(),
                                    builder: (context, custSnap) {
                                      final customers = custSnap.data ?? [];
                                      return DropdownButtonFormField<Customer>(
                                        initialValue:
                                            customers.isEmpty ||
                                                _selectedCustomerId == null
                                            ? null
                                            : customers.firstWhere(
                                                (customer) =>
                                                    customer.id ==
                                                    _selectedCustomerId,
                                                orElse: () => customers.first,
                                              ),
                                        decoration: InputDecoration(
                                          labelText: 'Customer',
                                          prefixIcon: const Icon(
                                            Icons.person_rounded,
                                            size: 20,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        items: customers
                                            .map(
                                              (customer) =>
                                                  DropdownMenuItem<Customer>(
                                                    value: customer,
                                                    child: Text(customer.name),
                                                  ),
                                            )
                                            .toList(),
                                        onChanged: _isWalkInSale
                                            ? null
                                            : (customer) => setState(
                                                () => _selectedCustomerId =
                                                    customer?.id,
                                              ),
                                        validator: _isWalkInSale
                                            ? null
                                            : (value) => value == null
                                                  ? 'Select a customer'
                                                  : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  StreamBuilder<List<Batch>>(
                                    stream: db.select(db.batches).watch(),
                                    builder: (context, batchSnap) {
                                      final batches = batchSnap.data ?? [];
                                      return DropdownButtonFormField<Batch>(
                                        initialValue:
                                            batches.isEmpty ||
                                                _selectedBatchId == null
                                            ? null
                                            : batches.firstWhere(
                                                (batch) =>
                                                    batch.id ==
                                                    _selectedBatchId,
                                                orElse: () => batches.first,
                                              ),
                                        decoration: InputDecoration(
                                          labelText: 'Batch',
                                          prefixIcon: const Icon(
                                            Icons.inventory_2_rounded,
                                            size: 20,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        items: batches
                                            .map(
                                              (batch) =>
                                                  DropdownMenuItem<Batch>(
                                                    value: batch,
                                                    child: Text(
                                                      batch.batchName,
                                                    ),
                                                  ),
                                            )
                                            .toList(),
                                        onChanged: (batch) => setState(
                                          () => _selectedBatchId = batch?.id,
                                        ),
                                        validator: (value) => value == null
                                            ? 'Select a batch'
                                            : null,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  InkWell(
                                    onTap: _pickSaleDate,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: 'Sale date',
                                        prefixIcon: const Icon(
                                          Icons.event_rounded,
                                          size: 20,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        DateFormat(
                                          'dd MMM yyyy, HH:mm',
                                        ).format(_saleDate),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _quantityController,
                                          focusNode: _quantityFocus,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) =>
                                              _onQuantitySubmitted(),
                                          validator: (value) {
                                            final qty =
                                                int.tryParse(value ?? '0') ?? 0;
                                            return qty <= 0
                                                ? 'Enter quantity'
                                                : null;
                                          },
                                          decoration: InputDecoration(
                                            labelText: 'Quantity Sold',
                                            prefixIcon: const Icon(
                                              Icons.numbers_rounded,
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _cashReceivedController,
                                          focusNode: _cashReceivedFocus,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d*'),
                                            ),
                                          ],
                                          textInputAction: TextInputAction.next,
                                          onFieldSubmitted: (_) =>
                                              _onCashReceivedSubmitted(),
                                          validator: (value) {
                                            final cash =
                                                double.tryParse(value ?? '') ??
                                                0.0;
                                            return cash <= 0
                                                ? 'Cash received required'
                                                : null;
                                          },
                                          decoration: InputDecoration(
                                            labelText:
                                                'Total Cash Received (₵)',
                                            prefixIcon: const Icon(
                                              Icons.attach_money_rounded,
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (!_isWorkerRole) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _unitPriceController,
                                            focusNode: _unitPriceFocus,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*'),
                                              ),
                                            ],
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_discountFocus),
                                            validator: (value) {
                                              final price =
                                                  double.tryParse(
                                                    value ?? '',
                                                  ) ??
                                                  0.0;
                                              return price <= 0
                                                  ? 'Enter unit price'
                                                  : null;
                                            },
                                            decoration: InputDecoration(
                                              labelText: 'Unit Price (₵)',
                                              prefixIcon: const Icon(
                                                Icons.price_change_rounded,
                                                size: 20,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _discountController,
                                            focusNode: _discountFocus,
                                            keyboardType:
                                                const TextInputType.numberWithOptions(
                                                  decimal: true,
                                                ),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d*\.?\d*'),
                                              ),
                                            ],
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_noteFocus),
                                            decoration: InputDecoration(
                                              labelText: 'Discount (₵)',
                                              prefixIcon: const Icon(
                                                Icons.discount_rounded,
                                                size: 20,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          initialValue: _paymentMethod,
                                          decoration: InputDecoration(
                                            labelText: 'Payment Type',
                                            prefixIcon: const Icon(
                                              Icons.payment_rounded,
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          items:
                                              const [
                                                    'Cash',
                                                    'Mobile Money',
                                                    'Bank Transfer',
                                                    'Credit',
                                                  ]
                                                  .map(
                                                    (method) =>
                                                        DropdownMenuItem(
                                                          value: method,
                                                          child: Text(method),
                                                        ),
                                                  )
                                                  .toList(),
                                          onChanged: (value) => setState(() {
                                            if (value != null) {
                                              _paymentMethod = value;
                                            }
                                          }),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _customerPhoneController,
                                          keyboardType: TextInputType.phone,
                                          decoration: InputDecoration(
                                            labelText: 'Customer Phone',
                                            prefixIcon: const Icon(
                                              Icons.phone_rounded,
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _noteController,
                                    focusNode: _noteFocus,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) =>
                                        _submitSalesWorkstationEntry(),
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: 'Invoice note or reference',
                                      prefixIcon: const Icon(
                                        Icons.notes_rounded,
                                        size: 20,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: _isSavingSale
                                            ? null
                                            : _submitSalesWorkstationEntry,
                                        icon: const Icon(
                                          Icons.check_circle_outline_rounded,
                                        ),
                                        label: Text(
                                          _isSavingSale
                                              ? 'Recording...'
                                              : 'Submit Sale',
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF16A34A,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _generateInvoiceAndSave,
                                        icon: const Icon(
                                          Icons.picture_as_pdf_rounded,
                                        ),
                                        label: const Text(
                                          'Generate Invoice PDF',
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _lastSavedInvoicePath == null
                                            ? null
                                            : _sendInvoiceToWhatsApp,
                                        icon: const Icon(Icons.chat_rounded),
                                        label: const Text('Send to WhatsApp'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_lastSavedInvoicePath != null) ...[
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Last invoice saved to: $_lastSavedInvoicePath',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            final invoicePath =
                                                _lastSavedInvoicePath;
                                            if (invoicePath == null) return;
                                            Clipboard.setData(
                                              ClipboardData(text: invoicePath),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Invoice path copied to clipboard',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.copy_rounded,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Customer balance cards
                Expanded(
                  child: StreamBuilder<List<Customer>>(
                    stream: (db.select(
                      db.customers,
                    )..where((t) => t.customerType.equals('CUSTOMER'))).watch(),
                    builder: (context, snapshot) {
                      final customers = snapshot.data ?? [];
                      final totalBalance = customers.fold(
                        0.0,
                        (s, c) => s + (c.balanceOwed),
                      );
                      final overdue = customers
                          .where((c) => (c.balanceOwed) > 0)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary strip
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _statCard(
                                'Total Customers',
                                '${customers.length}',
                                Icons.people_rounded,
                                const Color(0xFF3B82F6),
                                isNarrow,
                              ),
                              _statCard(
                                'Customers with Balance',
                                '${overdue.length}',
                                Icons.warning_amber_rounded,
                                const Color(0xFFF59E0B),
                                isNarrow,
                              ),
                              _statCard(
                                'Total Outstanding',
                                currency.format(totalBalance),
                                Icons.payments_rounded,
                                const Color(0xFF16A34A),
                                isNarrow,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Outstanding Balances',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // List
                          Expanded(
                            child: customers.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long_rounded,
                                          size: 64,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No customers found. Add customers in the Customer Directory.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: customers.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 10),
                                    itemBuilder: (context, i) {
                                      final c = customers[i];
                                      final balance = c.balanceOwed;
                                      return Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: balance > 0
                                                ? Colors.orange.withValues(
                                                    alpha: 0.3,
                                                  )
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.outline,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.04,
                                              ),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: const Color(
                                                0xFF16A34A,
                                              ).withValues(alpha: 0.1),
                                              child: Text(
                                                c.name[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Color(0xFF16A34A),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    c.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    c.phone ??
                                                        c.email ??
                                                        'No contact info',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  currency.format(balance),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14,
                                                    color: balance > 0
                                                        ? Colors.orange[700]
                                                        : Colors.green[700],
                                                  ),
                                                ),
                                                Text(
                                                  balance > 0
                                                      ? 'Outstanding'
                                                      : 'Settled',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: balance > 0
                                                        ? Colors.orange[400]
                                                        : Colors.green[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 8),
                                            if (balance > 0)
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.payment_rounded,
                                                  color: Colors.orange,
                                                  size: 20,
                                                ),
                                                tooltip: 'Settle Balance',
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                                onPressed: () =>
                                                    _showSettleDialog(c),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isCompact,
  ) {
    return Container(
      width: isCompact ? double.infinity : 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
