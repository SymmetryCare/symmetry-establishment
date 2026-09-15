class InventoryRepository {
  static String _inventory = '/inventory';
  static String _add = '/add';
  static String _byCompanyId = '/bycompanyId';

  // ── Fixed ──────────────────────────────────────────────────────────────────
  static String add = '$_inventory$_add';

  // ── Dynamic ────────────────────────────────────────────────────────────────
  static String getByCompanyId({required int companyId}) {
    return '$_inventory$_byCompanyId/$companyId';
  }

  static String update({required int inventoryId}) {
    return '$_inventory/$inventoryId';
  }

  static String delete({required int inventoryId}) {
    return '$_inventory/$inventoryId';
  }
}


class SupplyOrderRepository {
  static String _supplyOrders = '/supply-orders';
  static String _categories = '/categories';

  static String getCategories = '$_supplyOrders$_categories';
}