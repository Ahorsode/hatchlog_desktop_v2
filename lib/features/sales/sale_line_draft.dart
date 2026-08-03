import '../../utils/egg_log_utils.dart';
import '../../utils/sale_quantity_utils.dart';

enum SaleProductType { inventory, livestock, custom }

class SaleLineDraft {
  const SaleLineDraft({
    required this.productType,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.inventoryId,
    this.livestockId,
    this.eggAllocationMode,
    this.eggBatchId,
    this.eggQuantityUnit = EggSaleQuantityUnit.crate,
    this.lineDiscountAmount = 0,
    this.lineDiscountType = 'flat',
    this.eggsPerCrate = defaultEggsPerCrate,
  });

  final SaleProductType productType;
  final String description;
  /// Paid quantity in [eggQuantityUnit] for eggs, or birds for livestock.
  final int quantity;
  final double unitPrice;
  final String? inventoryId;
  final String? livestockId;
  final String? eggAllocationMode;
  final String? eggBatchId;
  final EggSaleQuantityUnit eggQuantityUnit;
  /// For `item` discounts this is free unit count; otherwise money or percent.
  final double lineDiscountAmount;
  final String lineDiscountType;
  final int eggsPerCrate;

  int get giveawayQuantity {
    if (lineDiscountType != 'item') {
      return 0;
    }
    return lineDiscountAmount.round().clamp(0, 999999);
  }

  int get stockQuantityDisplay =>
      saleQuantityWithGiveaway(quantity, giveawayQuantity);

  int get resolvedQuantityEggs {
    if (productType != SaleProductType.inventory) {
      return stockQuantityDisplay;
    }
    return saleQuantityInEggs(
      displayQuantity: stockQuantityDisplay,
      unit: eggQuantityUnit,
      eggsPerCrate: eggsPerCrate,
    );
  }

  double get lineSubtotal => quantity * unitPrice;

  double get lineDiscountValue => computeLineDiscount(
        lineSubtotal: lineSubtotal,
        discountAmount: lineDiscountAmount,
        discountType: lineDiscountType,
        unitPrice: unitPrice,
      );

  /// Billed total: paid units only for item giveaways (additive free stock).
  double get lineTotal {
    if (lineDiscountType == 'item') {
      return lineSubtotal.clamp(0, double.infinity);
    }
    return (lineSubtotal - lineDiscountValue).clamp(0, double.infinity);
  }

  double get resolvedUnitPricePerEgg {
    if (productType != SaleProductType.inventory) {
      return unitPrice;
    }
    return saleUnitPricePerEgg(
      displayUnitPrice: unitPrice,
      unit: eggQuantityUnit,
      eggsPerCrate: eggsPerCrate,
    );
  }
}
