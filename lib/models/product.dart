class Product {
  final int id;
  final String name;
  final String barcode;
  final double price;
  final int stockQty;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stockQty,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id:       json['id'],
      name:     json['name'],
      barcode:  json['barcode'],
      price:    double.parse(json['price'].toString()),
      stockQty: json['stock_qty'] ?? 0,
      imageUrl: json['image_url'],
    );
  }
}