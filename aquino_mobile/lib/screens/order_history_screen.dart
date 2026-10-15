import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/cart_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<PurchaseOrder>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = context.read<CartProvider>().loadOrderHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order history')),
      body: FutureBuilder<List<PurchaseOrder>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load order history.'));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No purchases yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) => _orderCard(orders[index]),
          );
        },
      ),
    );
  }

  Widget _orderCard(PurchaseOrder order) {
    final itemCount =
        order.products.fold(0, (sum, product) => sum + product.quantity);
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text('\$${order.total.toStringAsFixed(2)}'),
        subtitle: Text('${_formatDate(order.createdAt)} • $itemCount item(s)'),
        children: [
          for (final product in order.products)
            ListTile(
              dense: true,
              title: Text(product.title),
              subtitle: Text('Quantity: ${product.quantity}'),
              trailing: Text(
                '\$${(product.price * product.quantity).toStringAsFixed(2)}',
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }
}
