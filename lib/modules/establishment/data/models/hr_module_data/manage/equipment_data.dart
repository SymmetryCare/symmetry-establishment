class EquipmentData {
  final int employeeInventoryId;
  final int inventoryId;
  final String assignedDate;
  final int employeeId;
  final String givenId;
  final String inventoryTypeId;
  final String name;
  final int? fkCategoryId;
  final String? categoryName;
  final String? description;
  final String? inventoryStatus;

  EquipmentData({
    required this.employeeInventoryId,
    required this.inventoryId,
    required this.assignedDate,
    required this.employeeId,
    required this.givenId,
    required this.inventoryTypeId,
    required this.name,
    this.fkCategoryId,
    this.categoryName,
    this.description,
    this.inventoryStatus,
  });
}

class InventoryDropdownData {
  final int inventoryId;
  final String name;
  final int qty;
  final String description;
  final int companyId;

  InventoryDropdownData({
    required this.inventoryId,
    required this.name,
    required this.qty,
    required this.description,
    required this.companyId,
  });
}

class EquipmentPrefillData {
  final int empInventoryId;
  final int inventoryId;
  final String assignedDate;
  final int employeeId;
  final String givenId;
  final int inventoryTypeId;
  final String name;
  final String createdAt;
  final int? fkCategoryId;       // ← new

  EquipmentPrefillData({
    required this.empInventoryId,
    required this.inventoryId,
    required this.assignedDate,
    required this.employeeId,
    required this.givenId,
    required this.inventoryTypeId,
    required this.name,
    required this.createdAt,
    this.fkCategoryId,            // ← new
  });
}