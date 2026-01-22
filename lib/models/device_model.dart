class Device {
  final String id; 
  final String? ownerId;
  final String name;
  final String brand;
  final double pricePerDay;
  final String imageUrl;
  final bool isAvailable;
  final int maxRentalDays;
  final String condition;
  final String description;
  final String category;
  final List<DateTime> bookedSlots;
  final double? deposit;
  final String? specifications;
  final String? location;

  Device({
    required this.id,  
    this.ownerId,
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.imageUrl,
    required this.isAvailable,
    required this.maxRentalDays,
    required this.condition,
    required this.description,
    required this.category,
    required this.bookedSlots,
    this.deposit,
    this.specifications,
    this.location,
  });

  /// ===============================
  /// COPY WITH (IMMUTABLE UPDATE)
  /// ===============================
  Device copyWith({
    String? id,  
    String? ownerId,
    String? name,
    double? pricePerDay,
    bool? isAvailable,
    String? description,
    List<DateTime>? bookedSlots,
    String? imageUrl,
    double? deposit,
    String? specifications,
    String? location,
    int? maxRentalDays,
    String? condition,
    String? category,
    String? brand,
  }) {
    return Device(
      id: id ?? this.id,  
      ownerId: ownerId ?? this.ownerId, 
      name: name ?? this.name,
      brand: brand ?? this.brand,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      maxRentalDays: maxRentalDays ?? this.maxRentalDays,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      category: category ?? this.category,
      bookedSlots: bookedSlots ?? this.bookedSlots,
      deposit: deposit ?? this.deposit,
      specifications: specifications ?? this.specifications,
      location: location ?? this.location,
    );
  }

  /// ===============================
  /// FROM MAP (FACTORY CONSTRUCTOR)
  /// ===============================
  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id']?.toString() ?? '',  
      ownerId: map['user_id']?.toString(),
      name: map['name']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      pricePerDay: (map['price_per_day'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['image_url']?.toString() ?? '',
      isAvailable: map['is_available'] ?? true,
      maxRentalDays: (map['max_rental_days'] as num?)?.toInt() ?? 0,
      condition: map['condition']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      bookedSlots: (map['booked_slots'] as List<dynamic>? ?? [])
          .map((e) => DateTime.parse(e.toString()))
          .toList(),
      deposit: (map['deposit'] as num?)?.toDouble(),
      specifications: map['specifications']?.toString(),
      location: map['location']?.toString(),
    );
  }

  /// ===============================
  /// TO MAP (FOR SUPABASE)
  /// ===============================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': ownerId,
      'name': name,
      'brand': brand,
      'price_per_day': pricePerDay,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'max_rental_days': maxRentalDays,
      'condition': condition,
      'description': description,
      'category': category,
      'booked_slots': bookedSlots.map((e) => e.toIso8601String()).toList(),
      'deposit': deposit,
      'specifications': specifications,
      'location': location,
    };
  }

  /// ===============================
  /// EQUATABLE COMPARISON
  /// ===============================
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}