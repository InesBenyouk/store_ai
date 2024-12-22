class CartService {
  static final List<Map<String, dynamic>> _cartItems = [];

  static List<Map<String, dynamic>> get cartItems => _cartItems;

  static void addItem(Map<String, dynamic> item) {
    _cartItems.add(item);
  }

  static void removeItem(int index) {
    _cartItems.removeAt(index);
  }

  static void clearCart() {
    _cartItems.clear();
  }
}
