import 'package:drift/drift.dart' hide Column, Batch;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/local_db.dart';
import '../features/sales/sale_line_draft.dart';
import '../services/local_sales_service.dart';
import '../utils/farm_utils.dart';
import '../services/inventory_repository.dart';
import '../utils/egg_sale_allocation_utils.dart';
import '../utils/egg_log_utils.dart';
import '../utils/sale_payment_utils.dart';
import '../utils/sale_quantity_utils.dart';
import '../utils/inventory_sale_utils.dart';

enum _DiscountMode { flat, percentage, item }

String _desktopDiscountType(_DiscountMode mode) {
  switch (mode) {
    case _DiscountMode.percentage:
      return 'percent';
    case _DiscountMode.item:
      return 'item';
    case _DiscountMode.flat:
      return 'flat';
  }
}

class _ProductOption {
  const _ProductOption({
    required this.id,
    required this.label,
    required this.description,
    required this.unitPrice,
    required this.available,
    required this.productType,
  });

  final String id;
  final String label;
  final String description;
  final double unitPrice;
  final double available;
  final SaleProductType productType;
}

class _SaleLineState {
  SaleProductType productType = SaleProductType.inventory;
  String? productId;
  String description = '';
  EggAllocationMode eggAllocationMode = EggAllocationMode.fifo;
  String? eggBatchId;
  EggSaleQuantityUnit eggQuantityUnit = EggSaleQuantityUnit.crate;
  _DiscountMode lineDiscountMode = _DiscountMode.percentage;
  final TextEditingController quantityController = TextEditingController(text: '1');
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController customDescriptionController = TextEditingController();
  final TextEditingController lineDiscountController = TextEditingController(text: '0');

  void dispose() {
    quantityController.dispose();
    unitPriceController.dispose();
    customDescriptionController.dispose();
    lineDiscountController.dispose();
  }
}

Future<bool?> showSaleEntryDialog({
  required BuildContext context,
  required AppDatabase db,
  required List<Customer> customers,
  required List<Batch> batches,
  required List<InventoryItem> inventory,
  bool canOverridePrices = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => _SaleEntryDialog(
      db: db,
      customers: customers,
      batches: batches,
      inventory: inventory,
      canOverridePrices: canOverridePrices,
    ),
  );
}

class _SaleEntryDialog extends StatefulWidget {
  const _SaleEntryDialog({
    required this.db,
    required this.customers,
    required this.batches,
    required this.inventory,
    required this.canOverridePrices,
  });

  final AppDatabase db;
  final List<Customer> customers;
  final List<Batch> batches;
  final List<InventoryItem> inventory;
  final bool canOverridePrices;

  @override
  State<_SaleEntryDialog> createState() => _SaleEntryDialogState();
}

class _SaleEntryDialogState extends State<_SaleEntryDialog> {
  final _cashController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _paymentReferenceController = TextEditingController();
  final _paymentAccountNameController = TextEditingController();
  final _lines = [_SaleLineState()];
  late final LocalSalesService _salesService;

  String? _customerId;
  DateTime _orderDate = DateTime.now();
  _DiscountMode _discountMode = _DiscountMode.percentage;
  SalePaymentMethod _paymentMethod = SalePaymentMethod.cash;
  int _step = 1;
  bool _busy = false;
  bool _loading = true;
  String? _error;

  List<_ProductOption> _inventoryOptions = const [];
  List<_ProductOption> _livestockOptions = const [];
  List<InventoryItem> _eggInventoryItems = const [];
  List<EggBatchStockOption> _eggBatchOptions = const [];
  int _fifoTotalEggs = 0;
  Map<String, int> _fifoByCategoryId = const {};
  Map<String, double> _eggCategoryPrices = const {};
  int _eggsPerCrate = defaultEggsPerCrate;

  bool get _isWalkIn => _customerId == null;

  bool get _isCreditSale => _paymentMethod == SalePaymentMethod.credit;

  bool get _cashFieldEditable => widget.canOverridePrices || _isCreditSale;

  @override
  void initState() {
    super.initState();
    _salesService = LocalSalesService(widget.db);
    _initCatalog();
  }

  Future<void> _initCatalog() async {
    final farmId = await FarmUtils.getBoundFarmId();
    final prices = <String, double>{};
    if (farmId != null) {
      final settingsRow = await (widget.db.select(widget.db.farmSettings)
            ..where((t) => t.farmId.equals(farmId)))
          .getSingleOrNull();
      _eggsPerCrate = settingsRow?.eggsPerCrate ?? defaultEggsPerCrate;
      final rows = await widget.db.customSelect(
        'SELECT id, selling_price FROM egg_categories WHERE farm_id = ?',
        variables: [Variable.withString(farmId)],
      ).get();
      for (final row in rows) {
        prices[row.read<String>('id')] = row.read<double>('selling_price');
      }
    }

    final saleInventory = sellableEggInventory(widget.inventory);
    final eggBatchStock = farmId == null
        ? const ActiveBatchEggStock(totalEggs: 0, batches: [])
        : await InventoryRepository(widget.db).getActiveBatchEggStock(farmId);
    final fifoAvailability = farmId == null
        ? (totalEggs: 0, byCategoryId: <String, int>{})
        : await InventoryRepository(widget.db).getEggFifoAvailabilityMap(farmId);
    final inventoryOptions = saleInventory
        .map(
          (row) {
            final fifoEggs = _fifoEggsForInventoryItem(row, fifoAvailability);
            return _ProductOption(
              id: row.id,
              label:
                  '${formatSaleInventoryLabel(row)} (${formatEggStockCrateLabel(fifoEggs, eggsPerCrate: _eggsPerCrate)})',
              description: formatSaleInventoryLabel(row),
              unitPrice: inventoryItemSalePrice(
                row,
                eggCategoryPrices: prices,
              ),
              available: fifoEggs.toDouble(),
              productType: SaleProductType.inventory,
            );
          },
        )
        .toList(growable: false);
    final livestockOptions = widget.batches
        .where((batch) => batch.currentCount > 0)
        .map(
          (row) {
            final initialCost = row.initialActualCost ?? 0;
            final initialCount = row.initialCount <= 0 ? 1 : row.initialCount;
            return _ProductOption(
              id: row.id,
              label: row.batchName,
              description: row.batchName,
              unitPrice: initialCost / initialCount,
              available: row.currentCount.toDouble(),
              productType: SaleProductType.livestock,
            );
          },
        )
        .toList(growable: false);

    if (!mounted) {
      return;
    }
    setState(() {
      _inventoryOptions = inventoryOptions;
      _livestockOptions = livestockOptions;
      _eggInventoryItems = saleInventory;
      _eggCategoryPrices = prices;
      _eggBatchOptions = eggBatchStock.batches
          .map(
            (row) => EggBatchStockOption(
              batchId: row.batchId,
              batchName: row.batchName,
              eggsRemaining: row.eggsRemaining,
            ),
          )
          .toList(growable: false);
      _fifoTotalEggs = fifoAvailability.totalEggs;
      _fifoByCategoryId = fifoAvailability.byCategoryId;
      _loading = false;
      for (final line in _lines) {
        _autoSelectProduct(line);
      }
    });
    _syncCashReceived();
  }

  List<_ProductOption> _optionsFor(SaleProductType type) {
    return switch (type) {
      SaleProductType.inventory => _inventoryOptions,
      SaleProductType.livestock => _livestockOptions,
      SaleProductType.custom => const [],
    };
  }

  bool _shouldHideProductPicker(_SaleLineState line) {
    if (line.productType == SaleProductType.inventory) {
      return false;
    }
    if (line.productType == SaleProductType.custom) {
      return false;
    }
    final options = _optionsFor(line.productType);
    if (options.isEmpty) {
      return false;
    }
    return options.length == 1;
  }

  void _setEggProductFromRow(_SaleLineState line, InventoryItem row) {
    line.productId = row.id;
    line.description = formatSaleInventoryLabel(row);
    line.unitPriceController.text = inventoryItemSalePrice(
      row,
      eggCategoryPrices: _eggCategoryPrices,
    ).toStringAsFixed(2);
  }

  void _applyDefaultEggProduct(_SaleLineState line) {
    if (_eggInventoryItems.isEmpty) {
      line.productId = null;
      line.description = '';
      line.unitPriceController.clear();
      return;
    }
    if (!requiresEggSizeSelection(_eggInventoryItems)) {
      final row = defaultEggInventoryRow(_eggInventoryItems);
      if (row is InventoryItem) {
        _setEggProductFromRow(line, row);
      }
      return;
    }
    line.productId = null;
    line.description = 'Eggs';
    line.unitPriceController.clear();
  }

  int _eggAvailableForLine(_SaleLineState line) {
    if (line.eggAllocationMode == EggAllocationMode.batch) {
      if (line.eggBatchId == null || line.eggBatchId!.isEmpty) {
        return 0;
      }
      for (final batch in _eggBatchOptions) {
        if (batch.batchId == line.eggBatchId) {
          return batch.eggsRemaining;
        }
      }
      return 0;
    }
    final product = _inventoryOptions
        .where((option) => option.id == line.productId)
        .firstOrNull;
    return _fifoEggsForLine(line);
  }

  int _fifoEggsForInventoryItem(
    InventoryItem row,
    ({int totalEggs, Map<String, int> byCategoryId}) fifoAvailability,
  ) {
    if (isUnsortedEggInventoryItem(row)) {
      return fifoAvailability.totalEggs;
    }
    final categoryId = row.eggCategoryId?.trim() ?? '';
    if (categoryId.isNotEmpty) {
      return fifoAvailability.byCategoryId[categoryId] ?? 0;
    }
    return fifoAvailability.totalEggs;
  }

  int _fifoEggsForLine(_SaleLineState line) {
    final productId = line.productId;
    if (productId == null || productId.isEmpty) {
      return _fifoTotalEggs;
    }
    final item = _eggInventoryItems
        .where((row) => row.id == productId)
        .firstOrNull;
    if (item == null) {
      return _fifoTotalEggs;
    }
    if (isUnsortedEggInventoryItem(item)) {
      return _fifoTotalEggs;
    }
    final categoryId = item.eggCategoryId?.trim() ?? '';
    if (categoryId.isNotEmpty) {
      return _fifoByCategoryId[categoryId] ?? 0;
    }
    return _fifoTotalEggs;
  }

  bool get _needsCompletionPrompt {
    final cash = double.tryParse(_cashController.text.trim()) ?? 0;
    return _isCreditSale || (_computedTotal - cash).abs() > 0.01;
  }

  Future<void> _pickEggSizeForLine(int index) async {
    final line = _lines[index];
    final selected = await showDialog<InventoryItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select egg size'),
        content: SizedBox(
          width: 360,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final row in _eggInventoryItems)
                ListTile(
                  title: Text(eggSizeLabelFromRow(row)),
                  subtitle: Text('${row.stockLevel.floor()} in stock'),
                  onTap: () => Navigator.of(context).pop(row),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _setEggProductFromRow(line, selected);
      _syncCashReceived();
    });
  }

  void _autoSelectProduct(_SaleLineState line) {
    if (line.productType == SaleProductType.custom) {
      return;
    }
    if (line.productType == SaleProductType.inventory) {
      line.eggAllocationMode = EggAllocationMode.fifo;
      line.eggBatchId = null;
      _applyDefaultEggProduct(line);
      return;
    }
    final options = _optionsFor(line.productType);
    if (options.isEmpty) {
      line.productId = null;
      line.description = '';
      line.unitPriceController.clear();
      return;
    }
    if (options.length != 1) {
      return;
    }
    final selected = options.first;
    line.productId = selected.id;
    line.description = selected.description;
    line.unitPriceController.text = selected.unitPrice.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _cashController.dispose();
    _discountController.dispose();
    _paymentReferenceController.dispose();
    _paymentAccountNameController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  double _lineSubtotalFor(_SaleLineState line) {
    final quantity = int.tryParse(line.quantityController.text.trim()) ?? 0;
    final unitPrice = double.tryParse(line.unitPriceController.text.trim()) ?? 0;
    return quantity * unitPrice;
  }

  double _lineDiscountFor(_SaleLineState line) {
    final raw = double.tryParse(line.lineDiscountController.text.trim()) ?? 0;
    final subtotal = _lineSubtotalFor(line);
    if (line.lineDiscountMode == _DiscountMode.item) {
      return 0;
    }
    if (line.lineDiscountMode == _DiscountMode.percentage) {
      return (subtotal * raw / 100).clamp(0, subtotal);
    }
    return raw.clamp(0, subtotal);
  }

  double _lineTotalFor(_SaleLineState line) =>
      (_lineSubtotalFor(line) - _lineDiscountFor(line)).clamp(0, double.infinity);

  double get _subtotal {
    var total = 0.0;
    for (final line in _lines) {
      total += _lineTotalFor(line);
    }
    return LocalSalesService.roundMoney(total);
  }

  double get _discountAmount {
    final raw = double.tryParse(_discountController.text.trim()) ?? 0;
    if (_discountMode == _DiscountMode.percentage) {
      return LocalSalesService.roundMoney((_subtotal * raw / 100).clamp(0, _subtotal));
    }
    return LocalSalesService.roundMoney(raw.clamp(0, _subtotal));
  }

  double get _computedTotal =>
      LocalSalesService.roundMoney((_subtotal - _discountAmount).clamp(0, double.infinity));

  void _syncCashReceived() {
    if (!_isWalkIn && widget.canOverridePrices && !_isCreditSale) {
      return;
    }
    if (_isCreditSale) {
      return;
    }
    _cashController.text = _computedTotal.toStringAsFixed(2);
  }

  bool get _canContinueStep1 {
    if (_busy || _loading) {
      return false;
    }
    for (final line in _lines) {
      if (line.productType == SaleProductType.inventory &&
          _inventoryOptions.isEmpty) {
        return false;
      }
      if (line.productType == SaleProductType.inventory &&
          line.eggAllocationMode == EggAllocationMode.batch &&
          (line.eggBatchId == null || line.eggBatchId!.isEmpty)) {
        return false;
      }
      if (line.productId == null || line.productId!.isEmpty) {
        if (line.productType != SaleProductType.custom) {
          return false;
        }
      }
      if (line.productType == SaleProductType.inventory) {
        final displayQuantity = int.tryParse(line.quantityController.text.trim()) ?? 0;
        final giveaway = line.lineDiscountMode == _DiscountMode.item
            ? (double.tryParse(line.lineDiscountController.text.trim()) ?? 0)
                .round()
                .clamp(0, 999999)
            : 0;
        final quantityEggs = saleQuantityInEggs(
          displayQuantity: saleQuantityWithGiveaway(displayQuantity, giveaway),
          unit: line.eggQuantityUnit,
          eggsPerCrate: _eggsPerCrate,
        );
        if (quantityEggs > _eggAvailableForLine(line)) {
          return false;
        }
      }
    }
    return _computedTotal > 0;
  }

  bool get _canSubmitStep2 {
    if (!_canSubmit) {
      return false;
    }
    return validateSalePaymentFields(
      paymentMethod: _paymentMethod,
      paymentReference: _paymentReferenceController.text,
      paymentAccountName: _paymentAccountNameController.text,
      customerId: _customerId,
    ).isEmpty;
  }

  bool get _canSubmit {
    if (_busy || _loading) {
      return false;
    }
    for (final line in _lines) {
      if (line.productType == SaleProductType.inventory &&
          _inventoryOptions.isEmpty) {
        return false;
      }
      if (line.productType == SaleProductType.inventory &&
          line.eggAllocationMode == EggAllocationMode.batch &&
          (line.eggBatchId == null || line.eggBatchId!.isEmpty)) {
        return false;
      }
      if (line.productId == null || line.productId!.isEmpty) {
        if (line.productType != SaleProductType.custom) {
          return false;
        }
      }
      if (line.productType == SaleProductType.inventory) {
        final displayQuantity = int.tryParse(line.quantityController.text.trim()) ?? 0;
        final giveaway = line.lineDiscountMode == _DiscountMode.item
            ? (double.tryParse(line.lineDiscountController.text.trim()) ?? 0)
                .round()
                .clamp(0, 999999)
            : 0;
        final quantityEggs = saleQuantityInEggs(
          displayQuantity: saleQuantityWithGiveaway(displayQuantity, giveaway),
          unit: line.eggQuantityUnit,
          eggsPerCrate: _eggsPerCrate,
        );
        if (quantityEggs > _eggAvailableForLine(line)) {
          return false;
        }
      }
    }
    return true;
  }

  List<SaleLineDraft> _buildDrafts() {
    return _lines.map((line) {
      final quantity = int.parse(line.quantityController.text.trim());
      final unitPrice = double.parse(line.unitPriceController.text.trim());
      final description = line.productType == SaleProductType.custom
          ? line.customDescriptionController.text.trim()
          : line.description;
      return SaleLineDraft(
        productType: line.productType,
        description: description,
        quantity: quantity,
        unitPrice: unitPrice,
        inventoryId: line.productType == SaleProductType.inventory ? line.productId : null,
        livestockId: line.productType == SaleProductType.livestock ? line.productId : null,
        eggAllocationMode: line.productType == SaleProductType.inventory
            ? line.eggAllocationMode.name
            : null,
        eggBatchId: line.productType == SaleProductType.inventory &&
                line.eggAllocationMode == EggAllocationMode.batch
            ? line.eggBatchId
            : null,
        eggQuantityUnit: line.eggQuantityUnit,
        lineDiscountAmount:
            double.tryParse(line.lineDiscountController.text.trim()) ?? 0,
        lineDiscountType: _desktopDiscountType(line.lineDiscountMode),
        eggsPerCrate: _eggsPerCrate,
      );
    }).toList(growable: false);
  }

  Future<void> _submit({bool? completeNow}) async {
    if (!_canSubmit) {
      setState(() => _error = 'Complete every line item before saving.');
      return;
    }

    if (completeNow == null && _needsCompletionPrompt) {
      final choice = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Complete this sale now?'),
          content: const Text(
            'This credit or partial-payment sale can be completed now to deduct stock, or saved to complete later.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Skip for now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Complete sale now'),
            ),
          ],
        ),
      );
      if (choice == null || !mounted) {
        return;
      }
      return _submit(completeNow: choice);
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final farmId = await FarmUtils.getBoundFarmId();
      final userId = await FarmUtils.getRequiredUserId();
      if (farmId == null) throw Exception('Farm is not bound to this device.');

      final cash = double.parse(_cashController.text.trim());
      await _salesService.recordMultiLineSale(
        farmId: farmId,
        userId: userId,
        items: _buildDrafts(),
        orderDate: _orderDate,
        totalCashReceived: cash,
        customerId: _customerId,
        customerName: _customerId == null
            ? 'Walk-in Customer'
            : widget.customers.firstWhere((c) => c.id == _customerId).name,
        discountAmount: widget.canOverridePrices ? _discountAmount : 0,
        paymentMethod: _paymentMethod.apiValue,
        paymentReference: _paymentReferenceController.text.trim().isEmpty
            ? null
            : _paymentReferenceController.text.trim(),
        paymentAccountName: _paymentAccountNameController.text.trim().isEmpty
            ? null
            : _paymentAccountNameController.text.trim(),
        requireExactCashTotal:
            !_isWalkIn && !widget.canOverridePrices && !_isCreditSale,
        completeNow: completeNow,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Record Multi-Line Sale'),
      content: SizedBox(
        width: _step == 2 ? 560 : 520,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WizardStepChip(
                      label: '1. Customer & Products',
                      active: _step == 1,
                      completed: _step > 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _WizardStepChip(
                      label: '2. Payment',
                      active: _step == 2,
                      completed: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_step == 1) ...[
              DropdownButtonFormField<String?>(
                initialValue: _customerId,
                decoration: const InputDecoration(labelText: 'Customer'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Walk-in Customer')),
                  ...widget.customers.map(
                    (customer) => DropdownMenuItem(
                      value: customer.id,
                      child: Text(customer.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _customerId = value;
                  _syncCashReceived();
                }),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sale Date & Time'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_orderDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.event_outlined),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _orderDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (date == null || !mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_orderDate),
                    );
                    if (time == null || !mounted) return;
                    setState(() {
                      _orderDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
                ),
              ),
              for (var index = 0; index < _lines.length; index += 1)
                _LineEditor(
                  line: _lines[index],
                  canOverridePrices: widget.canOverridePrices,
                  eggsPerCrate: _eggsPerCrate,
                  inventoryTypeLabel: 'Eggs',
                  inventoryOptions: _inventoryOptions,
                  livestockOptions: _livestockOptions,
                  hideProductPicker: _shouldHideProductPicker(_lines[index]),
                  inventoryEmpty: _lines[index].productType ==
                          SaleProductType.inventory &&
                      _inventoryOptions.isEmpty,
                  eggBatchOptions: _eggBatchOptions,
                  requiresEggSizeSelection:
                      requiresEggSizeSelection(_eggInventoryItems),
                  onPickEggSize: () => _pickEggSizeForLine(index),
                  onProductTypeChanged: (type) {
                    setState(() {
                      final line = _lines[index];
                      line.productType = type;
                      line.productId = null;
                      line.eggAllocationMode = EggAllocationMode.fifo;
                      line.eggBatchId = null;
                      line.description = '';
                      line.unitPriceController.clear();
                      _autoSelectProduct(line);
                      _syncCashReceived();
                    });
                  },
                  onChanged: () => setState(_syncCashReceived),
                  onRemove: _lines.length == 1
                      ? null
                      : () {
                          setState(() {
                            _lines[index].dispose();
                            _lines.removeAt(index);
                            _syncCashReceived();
                          });
                        },
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    final line = _SaleLineState();
                    _lines.add(line);
                    _autoSelectProduct(line);
                    _syncCashReceived();
                  }),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Line'),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Line Subtotal'),
                trailing: Text('GH₵ ${_subtotal.toStringAsFixed(2)}'),
              ),
              ] else ...[
              if (widget.canOverridePrices) ...[
                SegmentedButton<_DiscountMode>(
                  segments: const [
                    ButtonSegment(value: _DiscountMode.flat, label: Text('Flat')),
                    ButtonSegment(value: _DiscountMode.percentage, label: Text('%')),
                  ],
                  selected: {_discountMode},
                  onSelectionChanged: (value) => setState(() {
                    _discountMode = value.first;
                    _syncCashReceived();
                  }),
                ),
                TextField(
                  controller: _discountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Discount'),
                  onChanged: (_) => setState(_syncCashReceived),
                ),
              ],
              DropdownButtonFormField<SalePaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: SalePaymentMethod.values
                    .map(
                      (method) => DropdownMenuItem(
                        value: method,
                        child: Text(method.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _paymentMethod = value;
                    _syncCashReceived();
                  });
                },
              ),
              if (_paymentMethod == SalePaymentMethod.mobileMoney) ...[
                TextField(
                  controller: _paymentReferenceController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'MoMo Phone Number'),
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: _paymentAccountNameController,
                  decoration: const InputDecoration(labelText: 'Account Holder Name'),
                  onChanged: (_) => setState(() {}),
                ),
              ] else if (_paymentMethod == SalePaymentMethod.bankTransfer)
                TextField(
                  controller: _paymentReferenceController,
                  decoration: const InputDecoration(labelText: 'Bank Reference (optional)'),
                  onChanged: (_) => setState(() {}),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Subtotal'),
                trailing: Text('GH₵ ${_subtotal.toStringAsFixed(2)}'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sale Total'),
                trailing: Text(
                  'GH₵ ${_computedTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              TextField(
                controller: _cashController,
                readOnly: !_cashFieldEditable,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Total Cash Received (GH₵)',
                  helperText: _isCreditSale
                      ? 'Credit sale: partial or zero payment allowed.'
                      : _isWalkIn
                      ? 'Walk-in sale: cash is locked to the sale total'
                      : widget.canOverridePrices
                          ? 'Credit sale: cash can differ from total.'
                          : 'Cash must equal the locked sale total.',
                  errorText: !_isCreditSale &&
                          !_isWalkIn &&
                          !widget.canOverridePrices &&
                          (_cashController.text.isNotEmpty) &&
                          ((double.tryParse(_cashController.text) ?? 0) - _computedTotal)
                                  .abs() >
                              0.01
                      ? 'Cash received must equal the locked sale total'
                      : null,
                ),
                onChanged: _cashFieldEditable ? (_) => setState(() {}) : null,
              ),
              ],
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        if (_step == 1)
          FilledButton(
            onPressed: _busy || !_canContinueStep1 ? null : () => setState(() => _step = 2),
            child: const Text('Continue'),
          )
        else ...[
          TextButton(
            onPressed: _busy ? null : () => setState(() => _step = 1),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: _busy || !_canSubmitStep2 ? null : _submit,
            child: Text(_busy ? 'Saving...' : 'Record Sale'),
          ),
        ],
      ],
    );
  }
}

class _WizardStepChip extends StatelessWidget {
  const _WizardStepChip({
    required this.label,
    required this.active,
    required this.completed,
  });

  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        color: active
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: active
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LineEditor extends StatelessWidget {
  const _LineEditor({
    required this.line,
    required this.canOverridePrices,
    required this.eggsPerCrate,
    required this.inventoryTypeLabel,
    required this.inventoryOptions,
    required this.livestockOptions,
    required this.hideProductPicker,
    required this.inventoryEmpty,
    required this.onProductTypeChanged,
    required this.onChanged,
    this.eggBatchOptions = const [],
    this.requiresEggSizeSelection = false,
    this.onPickEggSize,
    this.onRemove,
  });

  final _SaleLineState line;
  final bool canOverridePrices;
  final int eggsPerCrate;
  final String inventoryTypeLabel;
  final List<_ProductOption> inventoryOptions;
  final List<_ProductOption> livestockOptions;
  final bool hideProductPicker;
  final bool inventoryEmpty;
  final List<EggBatchStockOption> eggBatchOptions;
  final bool requiresEggSizeSelection;
  final VoidCallback? onPickEggSize;
  final ValueChanged<SaleProductType> onProductTypeChanged;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  List<_ProductOption> get _options => switch (line.productType) {
    SaleProductType.inventory => inventoryOptions,
    SaleProductType.livestock => livestockOptions,
    SaleProductType.custom => const [],
  };

  _ProductOption? get _selectedOption {
    for (final option in _options) {
      if (option.id == line.productId) {
        return option;
      }
    }
    return _options.isNotEmpty ? _options.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<SaleProductType>(
                    segments: [
                      ButtonSegment(
                        value: SaleProductType.inventory,
                        label: Text(inventoryTypeLabel),
                      ),
                      const ButtonSegment(
                        value: SaleProductType.livestock,
                        label: Text('Livestock'),
                      ),
                      if (canOverridePrices)
                        const ButtonSegment(
                          value: SaleProductType.custom,
                          label: Text('Custom'),
                        ),
                    ],
                    selected: {line.productType},
                    onSelectionChanged: (value) {
                      onProductTypeChanged(value.first);
                    },
                  ),
                ),
                if (onRemove != null)
                  IconButton(onPressed: onRemove, icon: const Icon(Icons.delete_outline)),
              ],
            ),
            const SizedBox(height: 8),
            if (line.productType == SaleProductType.custom)
              TextField(
                controller: line.customDescriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (_) => onChanged(),
              )
            else if (line.productType == SaleProductType.inventory &&
                !inventoryEmpty) ...[
              SegmentedButton<EggAllocationMode>(
                segments: const [
                  ButtonSegment(
                    value: EggAllocationMode.fifo,
                    label: Text('FIFO'),
                  ),
                  ButtonSegment(
                    value: EggAllocationMode.batch,
                    label: Text('By Batch'),
                  ),
                ],
                selected: {line.eggAllocationMode},
                onSelectionChanged: (selection) {
                  line.eggAllocationMode = selection.first;
                  if (selection.first == EggAllocationMode.fifo) {
                    line.eggBatchId = null;
                  }
                  onChanged();
                },
              ),
              const SizedBox(height: 8),
              if (line.eggAllocationMode == EggAllocationMode.batch) ...[
                if (eggBatchOptions.isEmpty)
                  InputDecorator(
                    decoration: const InputDecoration(labelText: 'Batch'),
                    child: Text(
                      'No active layer batches with eggs in stock',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  DropdownButtonFormField<String?>(
                    initialValue: line.eggBatchId,
                    decoration: const InputDecoration(labelText: 'Batch'),
                    items: [
                      for (final batch in eggBatchOptions)
                        DropdownMenuItem(
                          value: batch.batchId,
                          child: Text(
                            '${batch.batchName} (${batch.eggsRemaining} eggs)',
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      line.eggBatchId = value;
                      onChanged();
                    },
                  ),
                const SizedBox(height: 8),
              ],
              if (requiresEggSizeSelection)
                OutlinedButton.icon(
                  onPressed: onPickEggSize,
                  icon: const Icon(Icons.egg_outlined),
                  label: Text(
                    _selectedOption == null
                        ? 'Select egg size'
                        : 'Size: ${_selectedOption!.label}',
                  ),
                )
              else if (_selectedOption != null)
                InputDecorator(
                  decoration: InputDecoration(labelText: inventoryTypeLabel),
                  child: Text(
                    _selectedOption!.label,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ] else if (inventoryEmpty && line.productType == SaleProductType.inventory)
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Eggs Product'),
                child: Text(
                  'No eggs in stock — log egg production first',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            else if (hideProductPicker && _selectedOption != null)
              InputDecorator(
                decoration: InputDecoration(
                  labelText: line.productType == SaleProductType.inventory
                      ? inventoryTypeLabel
                      : 'Livestock Batch',
                ),
                child: Text(
                  _selectedOption!.label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              )
            else
              DropdownButtonFormField<String?>(
                initialValue: line.productId,
                decoration: InputDecoration(
                  labelText: line.productType == SaleProductType.inventory
                      ? '$inventoryTypeLabel Product'
                      : 'Livestock Batch',
                ),
                items: _options
                    .map(
                      (option) => DropdownMenuItem(
                        value: option.id,
                        child: Text(option.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  line.productId = value;
                  final selected = _options.where((option) => option.id == value).firstOrNull;
                  if (selected != null) {
                    line.description = selected.description;
                    line.unitPriceController.text = selected.unitPrice.toStringAsFixed(2);
                  }
                  onChanged();
                },
              ),
            const SizedBox(height: 8),
            if (line.productType == SaleProductType.inventory && !inventoryEmpty) ...[
              SegmentedButton<EggSaleQuantityUnit>(
                segments: const [
                  ButtonSegment(
                    value: EggSaleQuantityUnit.crate,
                    label: Text('Crates'),
                  ),
                  ButtonSegment(
                    value: EggSaleQuantityUnit.egg,
                    label: Text('Eggs'),
                  ),
                ],
                selected: {line.eggQuantityUnit},
                onSelectionChanged: (selection) {
                  final quantity =
                      int.tryParse(line.quantityController.text.trim()) ?? 0;
                  final unitPrice =
                      double.tryParse(line.unitPriceController.text.trim()) ?? 0;
                  if (selection.first == EggSaleQuantityUnit.egg) {
                    line.eggQuantityUnit = EggSaleQuantityUnit.egg;
                    line.quantityController.text = quantity > 0
                        ? (quantity * eggsPerCrate).toString()
                        : line.quantityController.text;
                    line.unitPriceController.text = eggsPerCrate > 0
                        ? (unitPrice / eggsPerCrate).toStringAsFixed(2)
                        : line.unitPriceController.text;
                  } else {
                    line.eggQuantityUnit = EggSaleQuantityUnit.crate;
                    line.quantityController.text = quantity > 0 && eggsPerCrate > 0
                        ? (quantity / eggsPerCrate).ceil().toString()
                        : line.quantityController.text;
                    line.unitPriceController.text =
                        (unitPrice * eggsPerCrate).toStringAsFixed(2);
                  }
                  onChanged();
                },
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: line.quantityController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: line.productType == SaleProductType.inventory
                          ? line.eggQuantityUnit == EggSaleQuantityUnit.crate
                              ? 'Crates'
                              : 'Eggs'
                          : 'Quantity',
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: line.unitPriceController,
                    readOnly: !canOverridePrices,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: line.productType == SaleProductType.inventory
                          ? line.eggQuantityUnit == EggSaleQuantityUnit.crate
                              ? 'Price / crate'
                              : 'Price / egg'
                          : 'Unit Price',
                    ),
                    onChanged: canOverridePrices ? (_) => onChanged() : null,
                  ),
                ),
              ],
            ),
            if (canOverridePrices) ...[
              const SizedBox(height: 8),
              SegmentedButton<_DiscountMode>(
                segments: const [
                  ButtonSegment(value: _DiscountMode.flat, label: Text('Flat')),
                  ButtonSegment(value: _DiscountMode.percentage, label: Text('%')),
                  ButtonSegment(value: _DiscountMode.item, label: Text('Free')),
                ],
                selected: {line.lineDiscountMode},
                onSelectionChanged: (selection) {
                  line.lineDiscountMode = selection.first;
                  onChanged();
                },
              ),
              TextField(
                controller: line.lineDiscountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: line.lineDiscountMode == _DiscountMode.item
                      ? 'Extra free crates (on top)'
                      : line.lineDiscountMode == _DiscountMode.percentage
                          ? 'Line Discount (%)'
                          : 'Line Discount (GHS)',
                ),
                onChanged: (_) => onChanged(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
