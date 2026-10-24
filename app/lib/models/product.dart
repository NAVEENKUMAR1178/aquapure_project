class Product {
  final String id, name, category, image, description;
  final num price, wholesalePrice;
  final int stock;
  Product(this.id, this.name, this.category, this.image, this.description,
      this.price, this.wholesalePrice, this.stock);
  factory Product.fromMap(String id, Map<String, dynamic> m) => Product(
      id, m['name'], m['category'], m['image'], m['description'] ?? '',
      m['price'], m['wholesalePrice'], m['stock'] ?? 0);
  num priceFor(bool dealer) => dealer ? wholesalePrice : price;
}

class CartItem {
  final Product product;
  int qty;
  CartItem(this.product, this.qty);
}
