import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final items = s.cart.values.toList();
    final min = s.isDealer ? s.minDealerQty : 1;
    final ok = items.isNotEmpty && items.every((c) => c.qty >= min);
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView(children: [
              for (final c in items)
                ListTile(
                  title: Text(c.product.name),
                  subtitle: Text('₹${c.product.priceFor(s.isDealer)} each'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => s.setQty(c.product.id, c.qty - 1)),
                    Text('${c.qty}'),
                    IconButton(icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => s.setQty(c.product.id, c.qty + 1)),
                  ]),
                ),
              if (s.isDealer && !ok)
                Padding(padding: const EdgeInsets.all(12),
                    child: Text('Dealer bulk orders need at least $min units per item.',
                        style: const TextStyle(color: Colors.red))),
            ]),
      bottomNavigationBar: items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(12),
              child: FilledButton(
                onPressed: ok
                    ? () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CheckoutScreen()))
                    : null,
                child: Text('Checkout · ₹${s.total}'),
              ),
            ),
    );
  }
}
