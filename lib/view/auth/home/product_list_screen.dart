import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductListScreen extends StatefulWidget {
  final String searchQuery;

  const ProductListScreen({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Device> _devices = [];
  List<Device> _filteredDevices = [];
  bool _isLoading = true;
  
  // Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color background = Color(0xFFF5F5F5);

  // Sort state
  String _currentSort = 'A-Z';
  
  // Filter states
  List<String> _selectedBrands = [];
  List<String> _selectedConditions = [];
  List<String> _selectedDurations = [];
  double _minPrice = 0;
  double _maxPrice = 50;
  bool _showAvailableOnly = false;
  
  // Available options
  final List<String> _allDurations = ['1 day', '7 days', '14 days', '60 days', '100 days'];
  final List<String> _allConditions = ['NEW', 'Rarely used', 'Heavily used'];
  final List<String> _allBrands = ['Apple', 'ASUS', 'Acer', 'Dell', 'Lenovo'];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _devices = _getSampleDevices();
        _filteredDevices = _devices;
        _isLoading = false;
      });
    });
  }

  List<Device> _getSampleDevices() {
    return [
      Device(
        id: '1',
        name: 'Lenovo Ideapad 3',
        brand: 'Lenovo',
        pricePerDay: 8.0,
        imageUrl: 'https://via.placeholder.com/150x100/4A90E2/FFFFFF?text=Lenovo',
        isAvailable: true,
        maxRentalDays: 60,
        condition: 'Rarely used',
      ),
      Device(
        id: '2',
        name: 'Acer Nitro V15',
        brand: 'Acer',
        pricePerDay: 10.0,
        imageUrl: 'https://via.placeholder.com/150x100/50E3C2/FFFFFF?text=Acer+Nitro',
        isAvailable: false,
        maxRentalDays: 60,
        condition: 'Like new',
      ),
      Device(
        id: '3',
        name: 'MacBook Air M1',
        brand: 'Apple',
        pricePerDay: 15.0,
        imageUrl: 'https://via.placeholder.com/150x100/9013FE/FFFFFF?text=MacBook',
        isAvailable: true,
        maxRentalDays: 30,
        condition: 'New',
      ),
      Device(
        id: '4',
        name: 'ASUS ROG Strix',
        brand: 'ASUS',
        pricePerDay: 12.0,
        imageUrl: 'https://via.placeholder.com/150x100/417505/FFFFFF?text=ASUS+ROG',
        isAvailable: true,
        maxRentalDays: 90,
        condition: 'Heavily used',
      ),
      Device(
        id: '5',
        name: 'Dell XPS 13',
        brand: 'Dell',
        pricePerDay: 11.0,
        imageUrl: 'https://via.placeholder.com/150x100/F5A623/FFFFFF?text=Dell+XPS',
        isAvailable: true,
        maxRentalDays: 45,
        condition: 'Rarely used',
      ),
      Device(
        id: '6',
        name: 'Samsung Galaxy Tab',
        brand: 'Samsung',
        pricePerDay: 7.0,
        imageUrl: 'https://via.placeholder.com/150x100/7ED321/FFFFFF?text=Galaxy+Tab',
        isAvailable: true,
        maxRentalDays: 14,
        condition: 'Good',
      ),
      Device(
        id: '7',
        name: 'Generic Gaming PC',
        brand: 'Other',
        pricePerDay: 25.0,
        imageUrl: 'https://via.placeholder.com/150x100/BD10E0/FFFFFF?text=Gaming+PC',
        isAvailable: false,
        maxRentalDays: 7,
        condition: 'Fair',
      ),
    ];
  }

  void _applySort(String sortType) {
    setState(() {
      _currentSort = sortType;
      List<Device> sortedList = List.from(_filteredDevices);
      
      switch (sortType) {
        case 'A-Z':
          sortedList.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Z-A':
          sortedList.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'Price: Low to High':
          sortedList.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
          break;
        case 'Price: High to Low':
          sortedList.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
          break;
        case 'Available First':
          sortedList.sort((a, b) => b.isAvailable ? 1 : -1);
          break;
        case 'Newest First':
          // Assuming newer items have higher IDs
          sortedList.sort((a, b) => int.parse(b.id).compareTo(int.parse(a.id)));
          break;
      }
      
      _filteredDevices = sortedList;
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredDevices = _devices.where((device) {
        // Brand filter
        if (_selectedBrands.isNotEmpty && !_selectedBrands.contains(device.brand)) {
          return false;
        }
        
        // Condition filter
        if (_selectedConditions.isNotEmpty) {
          String deviceCondition = _mapCondition(device.condition);
          if (!_selectedConditions.contains(deviceCondition)) {
            return false;
          }
        }
        
        // Duration filter
        if (_selectedDurations.isNotEmpty) {
          bool durationMatch = false;
          for (var duration in _selectedDurations) {
            if (_matchesDuration(device.maxRentalDays, duration)) {
              durationMatch = true;
              break;
            }
          }
          if (!durationMatch) return false;
        }
        
        // Price filter
        if (device.pricePerDay < _minPrice || device.pricePerDay > _maxPrice) {
          return false;
        }
        
        // Availability filter
        if (_showAvailableOnly && !device.isAvailable) {
          return false;
        }
        
        return true;
      }).toList();
      
      // Apply current sort after filtering
      _applySort(_currentSort);
    });
  }

  String _mapCondition(String condition) {
    if (condition.toLowerCase().contains('new') || condition == 'Rarely used') return 'New';
    if (condition.toLowerCase().contains('like new')) return 'Like New';
    if (condition.toLowerCase().contains('good')) return 'Good';
    if (condition.toLowerCase().contains('fair') || condition == 'Heavily used') return 'Fair';
    return 'Poor';
  }

  bool _matchesDuration(int days, String duration) {
    switch (duration) {
      case '1 day':
        return days >= 1;
      case '7 days':
        return days >= 7;
      case '14 days':
        return days >= 14;
      case '60 days':
        return days >= 60;
      case '100 days':
        return days >= 100;
      default:
        return true;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort By',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 16),
            ...['A-Z', 'Z-A', 'Price: Low to High', 'Price: High to Low', 'Available First', 'Newest First']
                .map((option) => RadioListTile(
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(),
                      ),
                      value: option,
                      groupValue: _currentSort,
                      activeColor: primaryBlue,
                      onChanged: (value) {
                        _applySort(value!);
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

void _showFilters() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      // Create local variables for the filter state
      double localMinPrice = _minPrice;
      double localMaxPrice = _maxPrice;
      List<String> localSelectedBrands = List.from(_selectedBrands);
      List<String> localSelectedDurations = List.from(_selectedDurations);
      List<String> localSelectedConditions = List.from(_selectedConditions);
      bool localShowAvailableOnly = _showAvailableOnly;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: ListView(
                    children: [
                      // Brand Filter
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Brand',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['Apple', 'ASUS', 'Acer', 'Dell', 'Lenovo'].map((brand) {
                                final isSelected = localSelectedBrands.contains(brand);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        localSelectedBrands.remove(brand);
                                      } else {
                                        localSelectedBrands.add(brand);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryBlue : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? primaryBlue : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      brand,
                                      style: GoogleFonts.poppins(
                                        color: isSelected ? Colors.white : textDark,
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      // Rent Duration Filter
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rent Duration',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['1 day', '7 days', '14 days', '60 days', '100 days'].map((duration) {
                                final isSelected = localSelectedDurations.contains(duration);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        localSelectedDurations.remove(duration);
                                      } else {
                                        localSelectedDurations.add(duration);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryBlue : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? primaryBlue : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      duration,
                                      style: GoogleFonts.poppins(
                                        color: isSelected ? Colors.white : textDark,
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      // Price Range Filter
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price Range',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Price range labels
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'rental fees',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: textLight,
                                      ),
                                    ),
                                    Text(
                                      'Min.price',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: textLight,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'rental fees',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: textLight,
                                      ),
                                    ),
                                    Text(
                                      'Max.price',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Range Slider
                            RangeSlider(
                              values: RangeValues(localMinPrice, localMaxPrice),
                              min: 0,
                              max: 50,
                              divisions: 10,
                              labels: RangeLabels(
                                'RM ${localMinPrice.toInt()}',
                                'RM ${localMaxPrice.toInt()}',
                              ),
                              activeColor: primaryBlue,
                              onChanged: (values) {
                                setState(() {
                                  localMinPrice = values.start;
                                  localMaxPrice = values.end;
                                });
                              },
                            ),
                            
                            // Current values display
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    'RM ${localMinPrice.toInt()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  'to',
                                  style: GoogleFonts.poppins(
                                    color: textLight,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Text(
                                    'RM ${localMaxPrice.toInt()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Condition Filter
                      Container(
                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Condition',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['NEW', 'Rarely used', 'Heavily used'].map((condition) {
                                final isSelected = localSelectedConditions.contains(condition);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        localSelectedConditions.remove(condition);
                                      } else {
                                        localSelectedConditions.add(condition);
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryBlue : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? primaryBlue : Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      condition,
                                      style: GoogleFonts.poppins(
                                        color: isSelected ? Colors.white : textDark,
                                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      
                      // Availability Filter
                      SwitchListTile(
                        title: Text(
                          'Show available only',
                          style: GoogleFonts.poppins(),
                        ),
                        value: localShowAvailableOnly,
                        activeColor: primaryBlue,
                        onChanged: (value) {
                          setState(() {
                            localShowAvailableOnly = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                
                // Buttons Row
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Reset Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              localSelectedBrands.clear();
                              localSelectedDurations.clear();
                              localSelectedConditions.clear();
                              localMinPrice = 0;
                              localMaxPrice = 50;
                              localShowAvailableOnly = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryBlue, width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Reset Changes',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryBlue,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Confirm Button
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Update main state
                            setState(() {
                              _selectedBrands = localSelectedBrands;
                              _selectedDurations = localSelectedDurations;
                              _selectedConditions = localSelectedConditions;
                              _minPrice = localMinPrice;
                              _maxPrice = localMaxPrice;
                              _showAvailableOnly = localShowAvailableOnly;
                            });
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

  void _resetFilters() {
    setState(() {
      _selectedBrands.clear();
      _selectedConditions.clear();
      _selectedDurations.clear();
      _minPrice = 0;
      _maxPrice = 50;
      _showAvailableOnly = false;
      _filteredDevices = _devices;
      _applySort(_currentSort);
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedBrands.isNotEmpty) count++;
    if (_selectedConditions.isNotEmpty) count++;
    if (_selectedDurations.isNotEmpty) count++;
    if (_minPrice > 0 || _maxPrice < 50) count++;
    if (_showAvailableOnly) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.searchQuery,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header with Sort and Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: const Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                Text(
                  '${_filteredDevices.length} results',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                
                // Active filters chip
                if (_getActiveFilterCount() > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryBlue.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${_getActiveFilterCount()} active',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Sort Button
                TextButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort, size: 18, color: Colors.black),
                  label: Text(
                    'Sort: $_currentSort',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                    ),
                  ),
                ),
                // Filter Button
                TextButton.icon(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.filter_list, size: 18, color: Colors.black),
                  label: Text(
                    'Filter',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Active filters display
          if (_getActiveFilterCount() > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Add filter chips here if you want to show individual active filters
                  if (_selectedBrands.isNotEmpty)
                    _buildFilterChip('${_selectedBrands.length} brands'),
                  if (_selectedConditions.isNotEmpty)
                    _buildFilterChip('${_selectedConditions.length} conditions'),
                  if (_selectedDurations.isNotEmpty)
                    _buildFilterChip('${_selectedDurations.length} durations'),
                  if (_minPrice > 0 || _maxPrice < 50)
                    _buildFilterChip('RM${_minPrice.toInt()}-${_maxPrice.toInt()}'),
                  if (_showAvailableOnly)
                    _buildFilterChip('Available only'),
                ],
              ),
            ),
          ],
          
          // Product List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDevices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No devices found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Try adjusting your filters',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredDevices.length,
                        itemBuilder: (context, index) {
                          final device = _filteredDevices[index];
                          return DeviceCard(device: device);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: primaryBlue,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              // This would remove individual filter
              // For now, just reset all
              _resetFilters();
            },
            child: Icon(Icons.close, size: 14, color: primaryBlue),
          ),
        ],
      ),
    );
  }
}

// Device Model
class Device {
  final String id;
  final String name;
  final String brand;
  final double pricePerDay;
  final String imageUrl;
  final bool isAvailable;
  final int maxRentalDays;
  final String condition;

  Device({
    required this.id,
    required this.name,
    required this.brand,
    required this.pricePerDay,
    required this.imageUrl,
    required this.isAvailable,
    required this.maxRentalDays,
    required this.condition,
  });
}

// Device Card Widget
class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Image
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(device.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Device Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${device.pricePerDay.toStringAsFixed(0)}/day',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: device.isAvailable ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: device.isAvailable ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: device.isAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            device.isAvailable ? 'Available' : 'Not Available',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: device.isAvailable ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Up to ${device.maxRentalDays} days',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Brand: ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      device.brand,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Condition: ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      device.condition,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}