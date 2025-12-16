// cart_item_fixed.dart
class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String condition;
  final String category;
  final String brand;
  final int maxRentalDays;
  final String location; // ✅ Device location
  bool isSelected;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.condition,
    required this.category,
    required this.brand,
    required this.maxRentalDays,
    required this.location,
    this.isSelected = true,
  });

  int get rentalDays => endDate.difference(startDate).inDays + 1;
  double get totalPrice => price * rentalDays;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'condition': condition,
      'category': category,
      'brand': brand,
      'max_rental_days': maxRentalDays,
      'location': location,
      'is_selected': isSelected,
      'total_price': totalPrice,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      image: map['image'],
      description: map['description'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      condition: map['condition'],
      category: map['category'],
      brand: map['brand'],
      maxRentalDays: map['max_rental_days'],
      location: map['location'],
      isSelected: map['is_selected'] ?? true,
    );
  }
}