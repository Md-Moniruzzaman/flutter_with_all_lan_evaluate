import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_evaluate/core/utility/constant.dart';
import 'package:flutter_evaluate/services/remote_script_service.dart';
import 'package:flutter_js/flutter_js.dart';

class Cartpage extends StatefulWidget {
  const Cartpage({super.key, required this.cartItems});
  final List<Map<String, dynamic>> cartItems;

  @override
  State<Cartpage> createState() => _CartpageState();
}

class _CartpageState extends State<Cartpage> {
  JavascriptRuntime? _jsRuntime;
  final RemoteScriptService _scriptService = RemoteScriptService();

  // To keep track of the calculated invoice details
  double _subtotal = 0.0;
  double _totalDiscount = 0.0;
  double _grandTotal = 0.0;
  bool _isInvoiceProcessed = false;

  @override
  void initState() {
    super.initState();
    _jsRuntime = getJavascriptRuntime();
  }

  @override
  void dispose() {
    _jsRuntime?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Order'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: widget.cartItems.isEmpty
          ? const Center(
              child: Text('Your cart is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return _buildCartItemCard(item);
                    },
                  ),
                ),
                _buildSummaryAndProcessButton(),
              ],
            ),
    );
  }

  Widget _buildCartItemCard(Map<String, dynamic> item) {
    final itemName = item['item_name']?.toString() ?? 'Unnamed Item';
    final orderQty = int.tryParse(item['order_qty']?.toString() ?? '0') ?? 0;
    final tp = double.tryParse(item['tp']?.toString() ?? '0') ?? 0.0;
    final vat = double.tryParse(item['vat']?.toString() ?? '0') ?? 0.0;
    final subtotal = orderQty * (tp + vat);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(itemName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4.0),
                  Text('Qty: $orderQty  |  Price: TK ${(tp + vat).toStringAsFixed(2)}'),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Text(
              'TK ${subtotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryAndProcessButton() {
    final totalItems = widget.cartItems.length;
    final totalQty = widget.cartItems.fold(
      0,
      (sum, item) => sum + (int.tryParse(item['order_qty']?.toString() ?? '0') ?? 0),
    );
    final totalAmt = widget.cartItems.fold(
      0.0,
      (sum, item) =>
          sum +
          ((double.tryParse(item['tp']?.toString() ?? '0') ?? 0.0) +
                  (double.tryParse(item['vat']?.toString() ?? '0') ?? 0.0)) *
              (double.tryParse(item['order_qty']?.toString() ?? '0') ?? 0.0),
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10)],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          Text(
            'Total: $totalItems Items | $totalQty pcs | TK ${totalAmt.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _processInvoice();
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0)),
              child: const Text('Process Invoice', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processInvoice() async {
    try {
      // 1. Get the JS code using the service (fetches from API, falls back to cache/asset)
      String jsCode = await _scriptService.getInvoiceProcessorScript();

      // 2. Serialize Dart data to JSON strings
      final cartItemsJson = jsonEncode(widget.cartItems);
      final flatRatesJson = jsonEncode(flatRate);
      final specialRatesJson = jsonEncode(specialRate);

      // 3. Inject the JSON data into the JS code
      jsCode = jsCode
          .replaceFirst('__CART_ITEMS__', cartItemsJson)
          .replaceFirst('__FLAT_RATES__', flatRatesJson)
          .replaceFirst('__SPECIAL_RATES__', specialRatesJson);

      // 4. Evaluate the JavaScript code
      final result = _jsRuntime?.evaluate(jsCode);
      final resultString = result?.stringResult ?? '{}';

      // 5. Parse the JSON result from JS and update the state
      final invoiceDetails = jsonDecode(resultString);

      setState(() {
        _subtotal = (invoiceDetails['subtotal'] as num?)?.toDouble() ?? 0.0;
        _totalDiscount = (invoiceDetails['totalDiscount'] as num?)?.toDouble() ?? 0.0;
        _grandTotal = (invoiceDetails['grandTotal'] as num?)?.toDouble() ?? 0.0;
        _isInvoiceProcessed = true;
      });

      _showInvoiceSummaryDialog();
    } catch (e) {
      // Handle any errors during JS evaluation
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error processing invoice: $e')));
    }
  }

  void _showInvoiceSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invoice Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Subtotal:', 'TK ${_subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildSummaryRow('Discount:', '- TK ${_totalDiscount.toStringAsFixed(2)}', color: Colors.green),
            const Divider(height: 20),
            _buildSummaryRow('Grand Total:', 'TK ${_grandTotal.toStringAsFixed(2)}', isBold: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              // Final confirmation logic
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
