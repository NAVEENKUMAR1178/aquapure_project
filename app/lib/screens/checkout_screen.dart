import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/app_state.dart';

// Razorpay TEST key (rzp_test_...) from dashboard -> Settings -> API Keys
const razorpayKey = 'rzp_test_REPLACE_ME';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final Razorpay rp;
  late final TextEditingController addr;

  @override
  void initState() {
    super.initState();
    addr = TextEditingController(
        text: context.read<AppState>().profile?['address'] ?? '');
    rp = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _ok)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _fail)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
  }

  @override
  void dispose() { rp.clear(); super.dispose(); }

  Future<void> _ok(PaymentSuccessResponse r) async {
    await context.read<AppState>().placeOrder(addr.text, r.paymentId ?? '');
    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Order placed!')));
  }

  void _fail(PaymentFailureResponse r) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Payment failed: ${r.message}')));

  void pay() {
    final s = context.read<AppState>();
    if (addr.text.trim().isEmpty) return;
    rp.open({
      'key': razorpayKey,
      'amount': (s.total * 100).toInt(),
      'name': 'AquaPure',
      'description': '${s.cart.length} item(s)',
      'prefill': {'contact': s.profile?['phone'] ?? '', 'email': s.user?.email ?? ''},
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        for (final c in s.cart.values)
          ListTile(dense: true, title: Text(c.product.name),
              trailing: Text('${c.qty} × ₹${c.product.priceFor(s.isDealer)}')),
        const Divider(),
        Text('Total: ₹${s.total}', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(controller: addr, maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Delivery address', border: OutlineInputBorder())),
        const SizedBox(height: 16),
        FilledButton(onPressed: pay, child: const Text('Pay with Razorpay (Test)')),
        const Text('Test card: 4111 1111 1111 1111, any future expiry, any CVV.',
            style: TextStyle(color: Colors.grey)),
      ]),
    );
  }
}
