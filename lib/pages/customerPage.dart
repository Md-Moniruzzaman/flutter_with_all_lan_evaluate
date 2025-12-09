import 'package:flutter/material.dart';
import 'package:flutter_evaluate/core/utility/constant.dart';
import 'package:flutter_evaluate/models/customer.dart';
import 'package:flutter_evaluate/pages/itemPage.dart';

class Customerpage extends StatefulWidget {
  const Customerpage({super.key});

  @override
  State<Customerpage> createState() => _CustomerpageState();
}

class _CustomerpageState extends State<Customerpage> {
  List<Customer> customers = [];

  Future<List<Customer>> fetchCustomers() async {
    // Implement your logic to fetch customers here
    return customerData.map((data) => Customer.fromJson(data)).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchCustomers().then((value) {
      setState(() {
        customers = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Page')),
      body: customers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ListView.builder(
                itemCount: customers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Itempage())),
                    title: _customerViewCard(customers[index]),
                  );
                },
              ),
            ),
    );
  }

  Widget _customerViewCard(Customer customer) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store, color: Colors.blueAccent, size: 28),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    customer.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    color: customer.status == 'ACTIVE' ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    customer.status,
                    style: TextStyle(
                      color: customer.status == 'ACTIVE' ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Divider(),
            const SizedBox(height: 8.0),
            _buildInfoRow(Icons.map_outlined, 'Territory', customer.territory),
            const SizedBox(height: 8.0),
            _buildInfoRow(Icons.location_city_outlined, 'Market/Thana/District', customer.marketThanaDistrict),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.0, color: Colors.grey.shade700),
        const SizedBox(width: 8.0),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: <TextSpan>[
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
