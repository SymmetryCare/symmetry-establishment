class InventoryData {
  final int inventoryId;
  final String name;
  final int qty;
  final String description;
  final int companyId;
  final String? sku;
  final num? price;
  final String? expiryDate;
  final int? fk_categoryId;
  final String? categoryName;

  InventoryData({
    required this.inventoryId,
    required this.name,
    required this.qty,
    required this.description,
    required this.companyId,
    this.sku,
    this.price,
    this.expiryDate,
    this.fk_categoryId,
    this.categoryName,
  });
}

class SupplyOrderCategoryData {
  final int categoryId;
  final String categoryName;

  SupplyOrderCategoryData({
    required this.categoryId,
    required this.categoryName,
  });
}