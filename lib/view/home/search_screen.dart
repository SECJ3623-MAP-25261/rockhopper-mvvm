import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this
import 'product_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _searchHistory = [
    'Laptop',
    'Phones',
    'Notebook',
    'Tablet',
    'Camera'
  ];
  
  // Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color chipBackground = Color(0xFFF0F8FF);

  // Popular categories
  final List<String> _popularCategories = [
    'Laptop',
    'Phone',
    'Camera',
    'Tablet',
    'Gaming',
    'VR Headset',
    'Smartwatch',
    'Speaker'
  ];

  // Smart suggestions data
  final Map<String, List<String>> _suggestions = {
    'laptop': ['Gaming Laptop', 'MacBook Pro', 'Laptop Charger', 'Laptop Bag'],
    'phone': ['iPhone 15', 'Samsung Galaxy', 'Phone Case', 'Screen Protector'],
    'camera': ['DSLR Camera', 'GoPro', 'Camera Lens', 'Tripod'],
    'tablet': ['iPad Air', 'Samsung Tablet', 'Tablet Stand', 'Stylus Pen'],
    'gaming': ['PlayStation 5', 'Xbox Series X', 'Gaming Mouse', 'Gaming Chair'],
  };

  List<String> _currentSuggestions = [];

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      // Add to history if not already there
      if (!_searchHistory.contains(query.trim())) {
        setState(() {
          _searchHistory.insert(0, query.trim());
          if (_searchHistory.length > 10) {
            _searchHistory.removeLast();
          }
        });
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductListScreen(searchQuery: query.trim()),
        ),
      );
    }
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory.clear();
    });
  }

  void _updateSuggestions(String query) {
    setState(() {
      _currentSuggestions = [];
      
      if (query.isEmpty) return;
      
      final queryLower = query.toLowerCase();
      
      // Check categories
      for (var category in _popularCategories) {
        if (category.toLowerCase().contains(queryLower)) {
          _currentSuggestions.add(category);
        }
      }
      
      // Check suggestion dictionary
      _suggestions.forEach((key, values) {
        if (key.contains(queryLower)) {
          _currentSuggestions.addAll(values);
        } else {
          for (var value in values) {
            if (value.toLowerCase().contains(queryLower)) {
              _currentSuggestions.add(value);
            }
          }
        }
      });
      
      // Remove duplicates and limit to 5
      _currentSuggestions = _currentSuggestions.toSet().toList().take(5).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _updateSuggestions(_searchController.text);
    });
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
          'Search',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Search devices, brands, categories...',
                  hintStyle: GoogleFonts.poppins(color: textLight),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: primaryBlue),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: textLight),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _currentSuggestions.clear();
                            });
                          },
                        )
                      : null,
                ),
                onSubmitted: _performSearch,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Smart Suggestions (if any)
            if (_currentSuggestions.isNotEmpty) ...[
              Text(
                'Suggestions',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _currentSuggestions.map((suggestion) {
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = suggestion;
                      _performSearch(suggestion);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: chipBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: primaryBlue.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            suggestion,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: primaryBlue),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            
            // Popular Categories
            Text(
              'Popular Categories',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularCategories.map((category) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = category;
                    _performSearch(category);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _getCategoryIcon(category),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Search History Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Searches',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
                if (_searchHistory.isNotEmpty)
                  TextButton(
                    onPressed: _clearSearchHistory,
                    child: Text(
                      'Clear all',
                      style: GoogleFonts.poppins(
                        color: primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Search History List
            Expanded(
              child: _searchHistory.isEmpty
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
                            'No recent searches',
                            style: GoogleFonts.poppins(
                              color: textLight,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Start searching for devices',
                            style: GoogleFonts.poppins(
                              color: textLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchHistory.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(
                            Icons.history,
                            color: primaryBlue.withOpacity(0.7),
                          ),
                          title: Text(
                            _searchHistory[index],
                            style: GoogleFonts.poppins(),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: textLight,
                            ),
                            onPressed: () {
                              _searchController.text = _searchHistory[index];
                              _performSearch(_searchHistory[index]);
                            },
                          ),
                          onTap: () {
                            _searchController.text = _searchHistory[index];
                            _performSearch(_searchHistory[index]);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get icon for category
  Icon _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'laptop':
        return const Icon(Icons.laptop_mac, size: 18, color: Color(0xFF2196F3));
      case 'phone':
        return const Icon(Icons.phone_iphone, size: 18, color: Color(0xFF4CAF50));
      case 'camera':
        return const Icon(Icons.camera_alt, size: 18, color: Color(0xFF9C27B0));
      case 'tablet':
        return const Icon(Icons.tablet_mac, size: 18, color: Color(0xFFFF9800));
      case 'gaming':
        return const Icon(Icons.videogame_asset, size: 18, color: Color(0xFFF44336));
      case 'vr headset':
        return const Icon(Icons.visibility, size: 18, color: Color(0xFF607D8B));
      case 'smartwatch':
        return const Icon(Icons.watch, size: 18, color: Color(0xFF795548));
      case 'speaker':
        return const Icon(Icons.speaker, size: 18, color: Color(0xFF009688));
      default:
        return const Icon(Icons.category, size: 18, color: Color(0xFF2196F3));
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }
}