import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class BusinessOwnerScreen extends StatefulWidget {
  final AppUser userProfile;

  const BusinessOwnerScreen({super.key, required this.userProfile});

  @override
  State<BusinessOwnerScreen> createState() => _BusinessOwnerScreenState();
}

class _BusinessOwnerScreenState extends State<BusinessOwnerScreen> {
  bool isCardView = false;
  String selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _products = [];

  // Categories for food items
  final List<String> categories = [
    'All',
    'Fast Food',
    'Chinese',
    'Pakistani',
    'Drinks',
    'Desserts',
    'Breakfast'
  ];

  // FIXED: Using Flutter local images or placeholder icons
  final List<Map<String, dynamic>> allProducts = [
    {
      'id': '1',
      'name': 'Chicken Biryani',
      'price': 250,
      'category': 'Pakistani',
      'description': 'Delicious chicken biryani with raita',
      'available': true,
      'icon': Icons.restaurant,
    },
    {
      'id': '2',
      'name': 'Chicken Burger',
      'price': 180,
      'category': 'Fast Food',
      'description': 'Juicy chicken burger with cheese',
      'available': true,
      'icon': Icons.fastfood,
    },
    {
      'id': '3',
      'name': 'Chicken Chow Mein',
      'price': 220,
      'category': 'Chinese',
      'description': 'Stir fried noodles with chicken',
      'available': true,
      'icon': Icons.ramen_dining,
    },
    {
      'id': '4',
      'name': 'Coca Cola',
      'price': 60,
      'category': 'Drinks',
      'description': 'Cold drink 250ml',
      'available': true,
      'icon': Icons.local_drink,
    },
    {
      'id': '5',
      'name': 'Chocolate Cake',
      'price': 150,
      'category': 'Desserts',
      'description': 'Fresh chocolate cake slice',
      'available': false,
      'icon': Icons.cake,
    },
    {
      'id': '6',
      'name': 'Chicken Karahi',
      'price': 300,
      'category': 'Pakistani',
      'description': 'Spicy chicken karahi',
      'available': true,
      'icon': Icons.restaurant,
    },
    {
      'id': '7',
      'name': 'Fried Rice',
      'price': 200,
      'category': 'Chinese',
      'description': 'Vegetable fried rice',
      'available': true,
      'icon': Icons.rice_bowl,
    },
    {
      'id': '8',
      'name': 'Omelette',
      'price': 120,
      'category': 'Breakfast',
      'description': '2 egg omelette with toast',
      'available': true,
      'icon': Icons.egg,
    },
    {
      'id': '9',
      'name': 'Pizza',
      'price': 350,
      'category': 'Fast Food',
      'description': 'Large cheese pizza',
      'available': true,
      'icon': Icons.local_pizza,
    },
    {
      'id': '10',
      'name': 'Fruit Juice',
      'price': 100,
      'category': 'Drinks',
      'description': 'Fresh orange juice',
      'available': true,
      'icon': Icons.emoji_food_beverage,
    },
    {
      'id': '11',
      'name': 'Nihari',
      'price': 280,
      'category': 'Pakistani',
      'description': 'Beef nihari with naan',
      'available': true,
      'icon': Icons.soup_kitchen,
    },
    {
      'id': '12',
      'name': 'Ice Cream',
      'price': 80,
      'category': 'Desserts',
      'description': 'Vanilla ice cream scoop',
      'available': true,
      'icon': Icons.icecream,
    },
  ];

  @override
  void initState() {
    super.initState();
    _products = allProducts;
  }

  void _searchProducts(String query) {
    setState(() {
      _products = allProducts.where((product) {
        final name = product['name'].toString().toLowerCase();
        final category = product['category'].toString().toLowerCase();
        final searchLower = query.toLowerCase();

        return name.contains(searchLower) ||
            category.contains(searchLower);
      }).toList();

      if (selectedCategory != 'All') {
        _products = _products.where((product) {
          return product['category'] == selectedCategory;
        }).toList();
      }
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        _products = allProducts;
      } else {
        _products = allProducts.where((product) {
          return product['category'] == category;
        }).toList();
      }

      if (_searchController.text.isNotEmpty) {
        _searchProducts(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        toolbarHeight: 90,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome ${widget.userProfile.name} 👋",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Food & Restaurant',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1)),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                isCardView ? Icons.view_list : Icons.grid_view_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  isCardView = !isCardView;
                });
              },
            ),
            const SizedBox(width: 10),
            const Icon(Icons.notifications_active_rounded,
                color: Colors.white, size: 26),
            const SizedBox(width: 14),
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.green, size: 26),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchProducts,
                decoration: InputDecoration(
                  hintText: 'Search food items...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _searchProducts('');
                    },
                  )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                    ),
                    onSelected: (selected) {
                      _filterByCategory(category);
                    },
                  ),
                );
              },
            ),
          ),

          // Products Grid/List
          Expanded(
            child: _products.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fastfood,
                    size: 80,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try searching for something else',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
                : isCardView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product, isList: true);
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product, isList: false);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, {bool isList = false}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showProductDetails(product);
        },
        child: isList ? _buildListCard(product) : _buildGridCard(product),
      ),
    );
  }

  Widget _buildListCard(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Product Icon instead of Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product['icon'] ?? Icons.fastfood,
              size: 40,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rs ${product['price']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product['available']
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product['available'] ? 'Available' : 'Out of Stock',
                        style: TextStyle(
                          fontSize: 10,
                          color: product['available'] ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildGridCard(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Icon Box
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    product['icon'] ?? Icons.fastfood,
                    size: 50,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  // Price Tag inside the box
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'Rs ${product['price']}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Product Name
          Text(
            product['name'],
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Category
          Text(
            product['category'],
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 8),

          // Availability
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product['available']
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product['available'] ? 'Available' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 10,
                    color: product['available'] ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // Add to cart button
              IconButton(
                onPressed: product['available'] ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${product['name']} to cart'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } : null,
                icon: Icon(
                  Icons.add_shopping_cart,
                  size: 18,
                  color: product['available'] ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Product Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Icon and Name
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product['icon'] ?? Icons.fastfood,
                        size: 50,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs ${product['price']}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: Colors.grey.shade300),

              // Details
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and Availability
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product['category'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: product['available']
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product['available'] ? 'Available' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: product['available']
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['description'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add to Cart Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: product['available'] ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${product['name']} to cart'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      product['available']
                          ? 'Add to Cart - Rs ${product['price']}'
                          : 'Out of Stock',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}