import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_evaluate/core/utility/constant.dart';
import 'package:flutter_evaluate/pages/cartPage.dart';
import 'package:flutter_evaluate/pages/settings_page.dart';

class Itempage extends StatefulWidget {
  const Itempage({super.key});

  @override
  State<Itempage> createState() => _ItempageState();
}

class _ItempageState extends State<Itempage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  Timer? _debounce;
  final ValueNotifier<List<Map<String, dynamic>>> _orderedItemsNotifier = ValueNotifier([]);

  Future<void> fetchItems() async {
    // Implement your logic to fetch items here
  }

  @override
  void initState() {
    super.initState();
    _filteredItems = itemData;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _orderedItemsNotifier.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _filterItems();
    });
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = itemData.where((item) {
        final itemName = item['item_name']?.toString().toLowerCase() ?? '';
        final itemId = item['item_id']?.toString().toLowerCase() ?? '';
        return itemName.contains(query) || itemId.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by name or ID',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),
          Expanded(
            child: _filteredItems.isEmpty
                ? const Center(
                    child: Text('No results found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) => ListTile(title: _itemViewCard(_filteredItems[index])),
                  ),
          ),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _orderedItemsNotifier,
            builder: (context, orderedItems, child) {
              return _buildAddToCart(
                context,
                totalItems: orderedItems.length.toString(),
                totalQty: orderedItems
                    .fold(0, (sum, item) => sum + (int.tryParse(item['order_qty']?.toString() ?? '0') ?? 0))
                    .toString(),
                totalAmt: orderedItems
                    .fold(
                      0.0,
                      (sum, item) =>
                          sum +
                          (((double.tryParse(item['tp']?.toString() ?? '0') ?? 0.0) +
                                  (double.tryParse(item['vat']?.toString() ?? '0') ?? 0.0)) *
                              (double.tryParse(item['order_qty']?.toString() ?? '0') ?? 0.0)),
                    )
                    .toStringAsFixed(2),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _itemViewCard(Map<String, dynamic> item) {
    return Card(
      elevation: 2.0,
      // margin: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.green, size: 28),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item['item_name'] ?? 'Unnamed Item'}",
                        // "${item['item_name'] ?? 'Unnamed Item'} | ${item['item_id'] ?? ''}",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 4.0),
                      Text(item['category_id'] ?? 'Unknown', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                _buildStockIndicator(context, item['stock']?.toString() ?? '0'),
              ],
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 8.0),
            _buildInfoRow(context, Icons.factory_outlined, 'Manufacturer', item['manufacturer'] ?? 'N/A'),
            const SizedBox(height: 8.0),
            _buildInfoRow(context, Icons.price_change_outlined, 'Price (TP)', 'TK ${item['tp'] ?? 0.0}'),
            const SizedBox(height: 12.0),
            _buildInputQtyRow('Quantity', '0', item),
          ],
        ),
      ),
    );
  }

  Widget _buildStockIndicator(BuildContext context, String stock) {
    final int stockCount = int.tryParse(stock) ?? 0;
    final bool inStock = stockCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: inStock ? Colors.cyan.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        inStock ? 'In Stock ($stock)' : 'Out of Stock',
        style: TextStyle(
          color: inStock ? Colors.cyan.shade800 : Colors.orange.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInputQtyRow(String label, String value, Map<String, dynamic> item) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
            ),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.end,
            initialValue: value,
            keyboardAppearance: Brightness.dark,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14),

            onChanged: (val) {
              // Handle quantity change
              final currentOrderedItems = List<Map<String, dynamic>>.from(_orderedItemsNotifier.value);
              final orderQty = int.tryParse(val) ?? 0;
              final existingItemIndex = currentOrderedItems.indexWhere(
                (element) => element['item_id'] == item['item_id'],
              );

              if (orderQty > 0) {
                // Update the item's order_qty
                item['order_qty'] = val;
                if (existingItemIndex != -1) {
                  currentOrderedItems[existingItemIndex] = item;
                } else {
                  currentOrderedItems.add(item);
                }
              } else {
                // If quantity is 0 or empty, remove the item from the ordered list
                currentOrderedItems.removeWhere((element) => element['item_id'] == item['item_id']);
              }
              _orderedItemsNotifier.value = currentOrderedItems;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18.0, color: Colors.grey.shade700),
        const SizedBox(width: 8.0),
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCart(
    BuildContext context, {
    String totalItems = '0',
    String totalQty = '0',
    String totalAmt = '0.0',
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Implement your add to cart logic here
          Navigator.push(context, MaterialPageRoute(builder: (_) => Cartpage(cartItems: _orderedItemsNotifier.value)));
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: Text('Add to Cart ($totalItems Items | $totalQty pcs | TK $totalAmt)'),

        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
    );
  }
}
